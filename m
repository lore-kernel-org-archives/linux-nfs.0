From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: PATCH - SUNRPC 1 of 3 - The new "sk_flags" word in struct svc_sock must be long....
Date: Wed, 21 Aug 2002 01:44:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15714.54388.413574.360810@charged.uio.no>
References: <15713.50328.541517.124690@notabene.cse.unsw.edu.au>
	<20020820185357.O21269@redhat.com>
	<shsy9b1yvcz.fsf@charged.uio.no>
	<20020820192158.P21269@redhat.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hIgC-0007jM-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 16:44:57 -0700
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: <20020820192158.P21269@redhat.com>
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

>>>>> " " == Benjamin LaHaise <bcrl@redhat.com> writes:

     > You've missed the point.  Between sk_inuse and sk_flags is 7
     > bytes of padding.  Yes, I'm aware that sk_flags has 7 bytes of
     > unused space, but that's the unavoidable part.  Personally, I
     > think the sunrpc code should do this particular operation
     > differently.

Fair enough: I agree that sk_flags could be moved to the top of the
struct. However in practice I doubt you'll see any gain whatsoever,
given that all the struct svc_sock get kmalloc()ed one by one...

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
