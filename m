From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS_UNSTABLE vs. FILE and DATA sync.
Date: Mon, 06 Aug 2007 14:58:30 -0400
Message-ID: <1186426710.6616.57.camel@localhost>
References: <A9AD3C3BCF83FD4182B7D4D99E37FAD836BEAB@exchrdm.ad.xensource.com>
	<46B74E5C.4060400@oracle.com>  <46B755FE.1010909@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Wim Colgate <Wim.Colgate@xensource.com>
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1II7mo-0003Sw-PB
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 11:58:39 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19KYs08YBljbzjsuZxZb6u+ILhtc57IC2o=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1II7mq-00054X-BC
	for nfs@lists.sourceforge.net; Mon, 06 Aug 2007 11:58:43 -0700
In-Reply-To: <46B755FE.1010909@oracle.com>
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

On Mon, 2007-08-06 at 13:10 -0400, Chuck Lever wrote:
> Even though an NFS client requests an NFS_FILE_SYNC write, the server 
> still has the choice of returning something less, even NFS_UNSTABLE.  In 
> general that's a rare occurrence, but is something I've seen in practice.

As Peter said, a server that return anything other than FILE_SYNC to a
FILE_SYNC write request would be in clear violation of the description
of WRITE semantics on page 51 of RFC1813:

      committed
         The server should return an indication of the level of
         commitment of the data and metadata via committed. If
         the server committed all data and metadata to stable
         storage, committed should be set to FILE_SYNC. If the
         level of commitment was at least as strong as
         DATA_SYNC, then committed should be set to DATA_SYNC.
         Otherwise, committed must be returned as UNSTABLE. If
         stable was FILE_SYNC, then committed must also be
         FILE_SYNC: anything else constitutes a protocol
         violation. If stable was DATA_SYNC, then committed may
         be FILE_SYNC or DATA_SYNC: anything else constitutes a
         protocol violation. If stable was UNSTABLE, then
         committed may be either FILE_SYNC, DATA_SYNC, or
         UNSTABLE.

I see no reason why we should care about supporting such a server.

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
