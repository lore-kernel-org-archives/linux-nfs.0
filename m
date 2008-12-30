From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 08/22] SUNRPC: pass buffer size to svc_addsock() and
	svc_sock_names()
Date: Tue, 30 Dec 2008 14:38:52 -0500
Message-ID: <20081230193852.GA28182@fieldses.org>
References: <20081212215340.24332.88416.stgit@ingres.1015granger.net> <20081212215804.24332.24605.stgit@ingres.1015granger.net> <20081225044306.GC17998@fieldses.org> <926E9A27-74B3-438D-B314-96CBE67697D9@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:48400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751971AbYL3Ti4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 30 Dec 2008 14:38:56 -0500
In-Reply-To: <926E9A27-74B3-438D-B314-96CBE67697D9@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 29, 2008 at 02:24:15PM -0500, Chuck Lever wrote:
> On Dec 24, 2008, at Dec 24, 2008, 11:43 PM, J. Bruce Fields wrote:
>> On Fri, Dec 12, 2008 at 04:58:05PM -0500, Chuck Lever wrote:
>>> Pass the size of the output buffer to the RPC functions that  
>>> construct
>>> the list of socket names in that buffer.  Add documenting comments to
>>> these functions.
>>>
>>> This is a cosmetic change for now.  A subsequent patch will make sure
>>> the buffer length is passed to one_sock_name(), where the length will
>>> actually be useful.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>>
>>> fs/nfsd/nfsctl.c               |   12 ++++++++----
>>> include/linux/sunrpc/svcsock.h |    6 ++++--
>>> net/sunrpc/svcsock.c           |   34 ++++++++++++++++++++++++++++ 
>>> +-----
>>> 3 files changed, 41 insertions(+), 11 deletions(-)
>>>
>>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>>> index 22fc8e5..19db9f4 100644
>>> --- a/fs/nfsd/nfsctl.c
>>> +++ b/fs/nfsd/nfsctl.c
>>> @@ -898,7 +898,7 @@ static ssize_t __write_ports_names(char *buf,  
>>> size_t size)
>>> static ssize_t __write_ports_addfd(char *buf, size_t size)
>>> {
>>> 	char *mesg = buf;
>>> -	int fd, err;
>>> +	int fd, err, len;
>>>
>>> 	err = get_int(&mesg, &fd);
>>> 	if (err || fd < 0)
>>> @@ -908,13 +908,16 @@ static ssize_t __write_ports_addfd(char *buf,  
>>> size_t size)
>>> 	if (err)
>>> 		return err;
>>>
>>> -	err = svc_addsock(nfsd_serv, fd, buf);
>>> +	len = SIMPLE_TRANSACTION_LIMIT;
>>> +	err = svc_addsock(nfsd_serv, fd, buf, len);
>>> 	if (err < 0)
>>> 		return err;
>>> +	len -= err;
>>>
>>> 	err = lockd_up();
>>> 	if (err < 0)
>>> -		svc_sock_names(buf + strlen(buf) + 1, nfsd_serv, buf);
>>> +		svc_sock_names(nfsd_serv, buf + strlen(buf) + 1,
>>> +				len - strlen(buf) - 1, buf);
>>
>> Since you already did len -= err above, aren't you effectly subtracing
>> off strlen(buf) twice here?
>
> Yeah, that's a bug, but relatively harmless.  I'll change that.
>
>> (And should that "len -= err" actually have
>> been a "len -= err + 1"?)
>
> Looking at this again, I think the pre-existing "+ 1" is incorrect.
>
> Say we have an 8 byte buffer, and svc_addsock() returns a 4-byte name,  
> let's say "xyz\n".
>
> It's my impression that we then want svc_sock_names() to start filling  
> in at the 5th byte in the buffer, which is buf[4] (or buf + 4) because C 
> arrays are indexed starting at zero.
>
> There are four bytes remaining in the buffer, so 8 - 4 = 4 is still  
> correct.
>
> So we want something like this:
>
> 	len = svc_addsock(nfsd_serv, fd, buf, SIMPLE_TRANSACTION_LIMIT);
> 	/* error checking snipped */
> 	svc_socknames(nfsd_serv, buf + len, SIMPLE_TRANSACTION_LIMIT - len,  
> buf);
>
> Do you agree?

Hm, sounds right.

> It's hard to see how today's nfs-utils would even exercise this case.   
> NFSD appears to open portlist for reading only to get the current set of 
> listeners; and when adding a new listener, it only writes.  I was not 
> able to find a case where it reads back what was written -- the portlist 
> file is opened WR_ONLY.

Could you try a test program?  I started with the below but didn't get
far.

--b.

#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/ip.h>
#include <fcntl.h>
#include <err.h>

int main(int argc, char *argv[])
{
	int fd;
	int so;
	int ret;
	char buf[1023];
	struct sockaddr_in addr = {
		.sin_family = AF_INET,
		.sin_port = 9999,
		.sin_addr = INADDR_ANY
	};

	so = socket(PF_INET, SOCK_STREAM, 0);
	if (so == -1)
		err(1, "socket");
	ret = bind(so, (struct sockaddr *)&addr, sizeof(struct sockaddr_in));
	fd = open("/proc/fs/nfsd/portlist", O_RDWR);
	if (ret == -1)
		err(1, "open");
	sprintf(buf, "%d\n", so);
	ret = write(fd, buf, strlen(buf));
	if (ret < strlen(buf))
		err(1, "write");
	ret = read(fd, buf, 0);
	if (ret < 0)
		err(1, "read");
	close(fd);
	printf("returned %d bytes: %s\n", ret, buf);
}
