From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Missing handling for NFS4ERR_OLD_STATEID in
	nfs4_handle_exception?
Date: Tue, 03 Apr 2007 09:09:49 -0700
Message-ID: <1175616589.3531.8.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HYlZr-0005H6-DZ
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:09:47 -0700
Received: from e1.ny.us.ibm.com ([32.97.182.141])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HYlZs-0000uW-F6
	for nfs@lists.sourceforge.net; Tue, 03 Apr 2007 09:09:49 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l33G8p0i014515
	for <nfs@lists.sourceforge.net>; Tue, 3 Apr 2007 12:08:51 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l33G8owI250170
	for <nfs@lists.sourceforge.net>; Tue, 3 Apr 2007 12:08:50 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l33G8oEU028250
	for <nfs@lists.sourceforge.net>; Tue, 3 Apr 2007 12:08:50 -0400
Received: from [9.47.22.153] (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l33G8oWg028224
	for <nfs@lists.sourceforge.net>; Tue, 3 Apr 2007 12:08:50 -0400
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

I'm looking at the following code, and wondering if something is missing
in the handling of NFS4ERR_OLD_STATEID. The result is that if this error
occurs, nfs4_map_errors() will print:

	nfs4_map_errors could not handle NFSv4 error 10024

It also looks like the handling of NFS4ERR_DELAY etc. may be wrong,
since if nfs4_delay() returns without error, it falls through to the
handling of NFS4ERR_OLD_STATEID.

Based on the code in nfs4_async_handle_error(), it looks like it might
be sufficient to set ret = 0 in addition to exception->retry = 1.

Thanks for any thoughts

Frank Filz

/* This is the error handling routine for processes that are allowed
 * to sleep.
 */
int nfs4_handle_exception(const struct nfs_server *server, int
errorcode, struct nfs4_exception *exception)
{
	struct nfs_client *clp = server->nfs_client;
	int ret = errorcode;

	exception->retry = 0;
	switch(errorcode) {
		case 0:
			return 0;
		case -NFS4ERR_STALE_CLIENTID:
		case -NFS4ERR_STALE_STATEID:
		case -NFS4ERR_EXPIRED:
			nfs4_schedule_state_recovery(clp);
			ret = nfs4_wait_clnt_recover(server->client, clp);
			if (ret == 0)
				exception->retry = 1;
			break;
		case -NFS4ERR_FILE_OPEN:
		case -NFS4ERR_GRACE:
		case -NFS4ERR_DELAY:
			ret = nfs4_delay(server->client, &exception->timeout);
			if (ret != 0)
				break;
		case -NFS4ERR_OLD_STATEID:
			exception->retry = 1;
	}
	/* We failed to handle the error */
	return nfs4_map_errors(ret);
}



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
