From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: Missing handling for NFS4ERR_OLD_STATEID
	in	nfs4_handle_exception?
Date: Thu, 12 Apr 2007 07:59:40 -0400
Message-ID: <461E1F2C.7000605@poochiereds.net>
References: <1175616589.3531.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, NFS List <nfs@lists.sourceforge.net>
To: Frank Filz <ffilzlnx@us.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hbxxt-0004hd-3s
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 04:59:49 -0700
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hbxxu-00010F-Bv
	for nfs@lists.sourceforge.net; Thu, 12 Apr 2007 04:59:51 -0700
In-Reply-To: <1175616589.3531.8.camel@dyn9047022153>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Frank Filz wrote:
> I'm looking at the following code, and wondering if something is missing
> in the handling of NFS4ERR_OLD_STATEID. The result is that if this error
> occurs, nfs4_map_errors() will print:
> 
> 	nfs4_map_errors could not handle NFSv4 error 10024
> 
> It also looks like the handling of NFS4ERR_DELAY etc. may be wrong,
> since if nfs4_delay() returns without error, it falls through to the
> handling of NFS4ERR_OLD_STATEID.
> 
> Based on the code in nfs4_async_handle_error(), it looks like it might
> be sufficient to set ret = 0 in addition to exception->retry = 1.
> 
> Thanks for any thoughts
> 
> Frank Filz
> 
> /* This is the error handling routine for processes that are allowed
>  * to sleep.
>  */
> int nfs4_handle_exception(const struct nfs_server *server, int
> errorcode, struct nfs4_exception *exception)
> {
> 	struct nfs_client *clp = server->nfs_client;
> 	int ret = errorcode;
> 
> 	exception->retry = 0;
> 	switch(errorcode) {
> 		case 0:
> 			return 0;
> 		case -NFS4ERR_STALE_CLIENTID:
> 		case -NFS4ERR_STALE_STATEID:
> 		case -NFS4ERR_EXPIRED:
> 			nfs4_schedule_state_recovery(clp);
> 			ret = nfs4_wait_clnt_recover(server->client, clp);
> 			if (ret == 0)
> 				exception->retry = 1;
> 			break;
> 		case -NFS4ERR_FILE_OPEN:
> 		case -NFS4ERR_GRACE:
> 		case -NFS4ERR_DELAY:
> 			ret = nfs4_delay(server->client, &exception->timeout);
> 			if (ret != 0)
> 				break;
> 		case -NFS4ERR_OLD_STATEID:
> 			exception->retry = 1;
> 	}
> 	/* We failed to handle the error */
> 	return nfs4_map_errors(ret);
> }
> 
> 

This looks pretty much correct to me as-is. If we set ret=0 on 
-NFS4ERR_OLD_STATEID, then the caller won't get back an error code. This 
makes an assumption that every caller of nfs4_handle_exception is 
looping based on exception->retry. I'm not sure if that's a safe 
assumption. A better idea *might* be to fix up nfs4_map_errors not to 
throw the warning for some errors < -1000, but still return an error.

This sounds sort of like addressing the symptom and not the real 
problem, however. The real question ought to be why you're getting 
OLD_STATEID errors back from the server here. There can be legit 
reasons, but these errors ought to be fairly rare. I generally only have 
seen them when processes are signalled while RPC requests are in flight.

Also, it seems like when we hit -NFS4ERR_DELAY, we want to retry but 
only if the delay didn't hit an error. It looks like it only returns 
error if process was signalled while in nfs4_delay, and then we want to 
pass an -ERESTARTSYS back up the call chain (and not retry). So I think 
that's also correct as-is.

-- Jeff


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
