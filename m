From: Ian Kent <raven@themaw.net>
Subject: Re: df hangs on down nfs server mounted with hard,intr, can't
 kill
Date: Wed, 10 Mar 2004 10:40:31 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0403101032520.23155@wombat.indigo.net.au>
References: <404E1BED.7090608@nsc1.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0tj0-0000xf-Fq
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 18:45:38 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0tZs-00047U-JC
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 18:36:12 -0800
To: Wade Hampton <wade.hampton@nsc1.net>
In-Reply-To: <404E1BED.7090608@nsc1.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 9 Mar 2004, Wade Hampton wrote:

> [I posted this to the Fedora list yesterday.]
> 
> I have a Fedora server with kernel 2.4.22-1-2163 SMP mounting a
> remote solaris server (hence choice of options):
> 
>   rsize=32768,ro,hard,intr,tcp,nfsvers=3
> 
> When the remote is down or disconnected, a "df" hangs (as expected),
> but I can't kill it, even as root or with kill -9.  The docs for mount 
> indicate
> that the INTR option should allow for killing apps mounted with HARD.
> Is this a bug (glibc, 2.4 kernel, NFS, or Fedora's kernel)?
> 

snip ...

> 
> 4)  Is there a perl module to accomplish this?

Perhaps you could convert this bit of code to perl. There would surely 
be access to the RPC libraries from perl.

If the server is down the timeout is several seconds longer than the 
timeout first time the routine is called (anyone care to comment as to 
why?) but at least it returns.

#include <rpc/rpc.h>
#include <nfs/nfs.h>
#include <linux/nfs2.h>
#include <rpc/xdr.h>
 
int rpc_ping(const char *host, long seconds, long micros)
{
	CLIENT *client;
	struct timeval tout;
	enum clnt_stat stat;

	client = clnt_create(host, NFS_PROGRAM, NFS2_VERSION, "udp");
	if (client == NULL) {
		return 0;
	}

	tout.tv_sec = seconds;
	tout.tv_usec = micros;

	clnt_control(client, CLSET_TIMEOUT, (char *)&tout);
	clnt_control(client, CLSET_RETRY_TIMEOUT, (char *)&tout);

	stat = clnt_call(client, NFSPROC_NULL,
			 (xdrproc_t)xdr_void, 0, (xdrproc_t)xdr_void, 0, tout);

	clnt_destroy(client);

	if (stat != RPC_SUCCESS) {
		return 0;
	}

	return 1;
}

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
