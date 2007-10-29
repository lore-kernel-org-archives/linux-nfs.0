From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 08/27] SUNRPC: Prevent length underflow
	in	read_flush()
Date: Mon, 29 Oct 2007 11:30:25 -0400
Message-ID: <4725FC91.4080705@oracle.com>
References: <20071026173120.31475.76007.stgit@manray.1015granger.net>
	<20071026184923.GI13033@fieldses.org>
Reply-To: chuck.lever@oracle.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010104070503030502010806"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Imd5P-0006GB-3u
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 15:27:58 -0700
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Imd5T-0006lR-Ct
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 15:28:00 -0700
In-Reply-To: <20071026184923.GI13033@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a multi-part message in MIME format.
--------------010104070503030502010806
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

J. Bruce Fields wrote:
> On Fri, Oct 26, 2007 at 01:31:20PM -0400, Chuck Lever wrote:
>> Make sure we compare an unsigned length to an unsigned count in
>> read_flush().
> 
> OK by me, thanks.  This motivated by the hope of being able to turn on
> more compile warnings some day?

The long-term goal is cleaner, less buggy code overall.  One tactic to 
reach this goal is enabling the use of automated code checking tools.

>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>>
>>  net/sunrpc/cache.c |   10 +++++-----
>>  1 files changed, 5 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
>> index 8e05557..578084f 100644
>> --- a/net/sunrpc/cache.c
>> +++ b/net/sunrpc/cache.c
>> @@ -1242,18 +1242,18 @@ static ssize_t read_flush(struct file *file, char __user *buf,
>>  	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
>>  	char tbuf[20];
>>  	unsigned long p = *ppos;
>> -	int len;
>> +	size_t len;
>>  
>>  	sprintf(tbuf, "%lu\n", cd->flush_time);
>>  	len = strlen(tbuf);
>>  	if (p >= len)
>>  		return 0;
>>  	len -= p;
>> -	if (len > count) len = count;
>> +	if (len > count)
>> +		len = count;
>>  	if (copy_to_user(buf, (void*)(tbuf+p), len))
>> -		len = -EFAULT;
>> -	else
>> -		*ppos += len;
>> +		return -EFAULT;
>> +	*ppos += len;
>>  	return len;
>>  }
>>  
>>
>>
>> -------------------------------------------------------------------------
>> This SF.net email is sponsored by: Splunk Inc.
>> Still grepping through log files to find problems?  Stop.
>> Now Search log events and configuration files using AJAX and a browser.
>> Download your FREE copy of Splunk now >> http://get.splunk.com/
>> _______________________________________________
>> NFS maillist  -  NFS@lists.sourceforge.net
>> https://lists.sourceforge.net/lists/listinfo/nfs

--------------010104070503030502010806
Content-Type: text/x-vcard; charset=utf-8;
 name="chuck.lever.vcf"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="chuck.lever.vcf"

begin:vcard
fn:Chuck Lever
n:Lever;Chuck
org:Oracle Corporation;Corporate Architecture: Linux Projects Group
adr:;;1015 Granger Avenue;Ann Arbor;MI;48104;USA
title:Principal Member of Staff
tel;work:+1 248 614 5091
x-mozilla-html:FALSE
version:2.1
end:vcard


--------------010104070503030502010806
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--------------010104070503030502010806
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------010104070503030502010806--
