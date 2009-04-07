From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 3/5] nfs-utils: query for remote port using rpcbind
	instead of getaddrinfo
Date: Tue, 7 Apr 2009 12:29:23 -0400
Message-ID: <65C78FA4-2A84-498E-8857-BBB6F59B206C@oracle.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
	<1239117946-7535-4-git-send-email-jlayton@redhat.com>
	<41F98279-F000-4C1C-8E44-3568C89FC2BD@oracle.com>
	<20090407162005.GC24157@fieldses.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090407162005.GC24157@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr 7, 2009, at 12:20 PM, J. Bruce Fields wrote:
> On Tue, Apr 07, 2009 at 12:02:46PM -0400, Chuck Lever wrote:
>>
>> On Apr 7, 2009, at 11:25 AM, Jeff Layton wrote:
>>
>>> We already have the server's address from the upcall, so we don't
>>> really
>>> need to look it up again, and querying the local services DB for the
>>> port that the remote server is listening on is just plain wrong.
>>>
>>> Use rpcbind to set the port for the program and version that we were
>>> given in the upcall. The exception here is NFSv4. Since NFSv4 mounts
>>> are supposed to use a well-defined port then skip the rpcbind query
>>> for that and just set the port to the standard one (2049).
>>>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>> utils/gssd/gssd_proc.c |  126 ++++++++++++++++++++++++++++
>>> +-------------------
>>> 1 files changed, 76 insertions(+), 50 deletions(-)
>>>
>>> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
>>> index 9d3712b..1571329 100644
>>> --- a/utils/gssd/gssd_proc.c
>>> +++ b/utils/gssd/gssd_proc.c
>>> @@ -72,6 +72,7 @@
>>> #include "gss_util.h"
>>> #include "krb5_util.h"
>>> #include "context.h"
>>> +#include "nfsrpc.h"
>>>
>>> /*
>>> * pollarray:
>>> @@ -541,6 +542,64 @@ out_err:
>>> }
>>>
>>> /*
>>> + * If the port isn't already set, do an rpcbind query to the remote
>>> server
>>> + * using the program and version and get the port. Newer kernels
>>> send the
>>> + * port in the upcall, so this is really only for compatibility
>>> with older
>>> + * ones.
>>> + */
>>> +static int
>>> +populate_port(struct sockaddr *sa, const socklen_t salen,
>>> +	      const rpcprog_t program, const rpcvers_t version,
>>> +	      const unsigned short protocol)
>>> +{
>>> +	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
>>> +	unsigned short		port;
>>> +
>>> +	/*
>>> +	 * Newer kernels send the port in the upcall. If we already have
>>> +	 * the port, there's no need to look it up.
>>> +	 */
>>> +	switch (sa->sa_family) {
>>> +	case AF_INET:
>>> +		if (s4->sin_port != 0) {
>>> +			printerr(2, "DEBUG: port already set to %d\n",
>>> +				 ntohs(s4->sin_port));
>>> +			return 1;
>>> +		}
>>> +		break;
>>> +	default:
>>> +		printerr(0, "ERROR: unsupported address family %d\n",
>>> +			    sa->sa_family);
>>> +		return 0;
>>> +	}
>>> +
>>> +	/* Use standard NFS port for NFSv4 */
>>> +	if (program == 100003 && version == 4) {
>>> +		port = 2049;
>>> +		goto set_port;
>>> +	}

And actually, since this test is _after_ the check to see if zero was  
passed in, I think we probably get correct behavior here if the kernel  
passes a non-zero port value for an NFSv4 mount.  My mistake.

>> I think this patch set looks pretty reasonable.  Here's my one
>> remaining quibble.
>>
>> You can specify "port=" for nfs4 mounts, in which case we want to use
>> that value here, too, I think.  It would be simpler overall if the
>> kernel always passed up the value it is using for port= on this mount
>> point.
>>
>> The rules for how the kernel uses the port= setting are:
>>
>>  + if port= is not specified on NFSv2/v3, port= setting is zero
>>  + if port= is not specified on NFSv4, port= setting is 2049
>>
>> Then, when setting up a tranport:
>>
>>  + if the port= setting is zero, do an rpcbind
>>  + if the port= setting is not zero, use that value
>>
>> If the kernel always passes the port= setting to gssd, then it can
>> follow the "if port value is zero, rpcbind; otherwise use port value
>> as is" rule, and be sure to get correct NFSv4 behavior, even without
>> the special case you added for NFSv4.
>
> In recent kernels that information is in the "info" file for the given
> client in rpc_pipefs.  Kevin and Olga have patches to support that in
> gssd, if they aren't already in upstream nfs-utils.

The issue is we're not exactly sure what value the kernel is passing  
up in the info file.  It seems to change over time.

> And of course it's important to use that when it's available, to avoid
> unnecessary rpcbind calls (in a pure nfsv4 environment the only  
> firewall
> hole you should have to poke is for the nfsv4 port), to respect the
> port= mount option for people running a v4 server on an alternate  
> port,
> and for authenticating the callback channel (which won't normally be  
> to
> port 2049, and won't (I assume) normally be registered with the
> portmapper).

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
