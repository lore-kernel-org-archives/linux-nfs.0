From: Dumas Patrice <dumas@centre-cired.fr>
Subject: Re: 3 strange things in the lockd code ?
Date: Mon, 8 Apr 2002 14:54:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020408145459.B12049@zeus.centre-cired.fr>
References: <20020404194238.E25342@zeus.centre-cired.fr> <shs8z7yo0ml.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from boukha.centre-cired.fr ([193.51.120.234])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uYjD-00039Q-00
	for <nfs@lists.sourceforge.net>; Mon, 08 Apr 2002 05:58:35 -0700
Received: from zeus.centre-cired.fr ([193.51.120.192])
          by boukha.centre-cired.fr (8.9.3+Sun/jtpda-5.3.3) with ESMTP id OAA28622
          for <nfs@lists.sourceforge.net>; Mon, 8 Apr 2002 14:57:44 +0100 (WEST)
Received: (from dumas@localhost)
	by zeus.centre-cired.fr (8.11.6/8.11.6) id g38CsxZ13249
	for nfs@lists.sourceforge.net; Mon, 8 Apr 2002 14:54:59 +0200
To: nfs@lists.sourceforge.net
In-Reply-To: <shs8z7yo0ml.fsf@charged.uio.no>; from trond.myklebust@fys.uio.no on Mon, Apr 08, 2002 at 02:06:42PM +0200
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi,

> NLM_GRANTED_RES is part of the 'asynchronous RPC' NLM model which was
> designed to support locking on systems without monitoring
> (i.e. without rpc.statd').
> Linux does not currently support such a model, nor do we really plan
> to do so. Non-monitored locks are pretty hairy things to deal with
> (see http://www.opengroup.org/onlinepubs/9629799/chap9.htm#tagcjh_10_01_01_02).

Are you sure about that ?
After reading the code and the page you send me, I tend to disagree. My
undersstanding is that non-monitored locks are only concerned with the
NLM_NM_LOCK - Non-monitored Lock callback.

I didn't saw something really saying non-monitored clients aren't allowed to do
NLM_LOCK or NLM_LOCK_MSG, but I assume they aren't. However I am pretty sure
that monitored clients can do NLM_LOCK_MSG and thus they can receive in turn
NLM_GRANTED_MSG, which should trigger them to send a NLM_GRANTED_RES. And
indeed the dmesg output I send in a mail with subject "lockd bug (?)" shows
linux nfs clients do send NLM_GRANTED_MSG.

> I agree. We should be checking the host address as well.

I will try to make a patch.

Cheers

Pat

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
