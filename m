From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: Re: [PATCH] resend: knfsd multiple UDP sockets
Date: Wed, 2 Jun 2004 09:19:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16573.3856.840390.991081@cse.unsw.edu.au>
References: <20040528042007.GA9014@sgi.com>
	<16566.51874.43089.537506@cse.unsw.edu.au>
	<40BCAD5F.4DE90B76@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>,
    Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVIY7-0006QA-GJ
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 16:20:03 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVIY7-0006EN-4C
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 16:20:03 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <ewhiting@amis.com>) (for <gnb@sgi.com>)
	(for <nfs@lists.sourceforge.net>) By note With Smtp ;
	Wed, 2 Jun 2004 09:19:50 +1000
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: message from Eric Whiting on Tuesday June 1
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

On Tuesday June 1, ewhiting@amis.com wrote:
> Neil Brown wrote:
> >
> > I have two concerns, that can possibly be allayed.
> > 
> > Firstly, the reply to any request is going to go out the socket that
> > the request came in on.  However some network configurations can have
> > requests arrive on one interface that need to be replied to on a
> > different interface(*).  
> 
> Neil,
> 
> Some misc data: It is my understanding that 'networkappliance data ontap' is
> wired up to send replies out the same interface the request came in on. This
> solves some problems of managing systems connected via multiple network paths. 
> I realize it might also create other problems..
> 
> eric

Interesting. Thanks.
It may well be reasonable to have a mode of operation where all
replies go out the interfaces that the requests come in on, and which
utilises the simplification to increase performance.
But it would have to optional and non-default, and I would want to
have a better understanding of the issues, and whether it is the best
way to improve performance.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
