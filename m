From: Greg Banks <gnb@sgi.com>
Subject: Re: Re: [PATCH] resend: knfsd multiple UDP sockets
Date: Wed, 2 Jun 2004 10:47:45 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040602004745.GA32206@sgi.com>
References: <20040528042007.GA9014@sgi.com> <16566.51874.43089.537506@cse.unsw.edu.au> <40BCAD5F.4DE90B76@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVJvF-0007AV-RK
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 17:48:01 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BVJvF-0003wr-44
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 17:48:01 -0700
To: Eric Whiting <ewhiting@amis.com>
In-Reply-To: <40BCAD5F.4DE90B76@amis.com>
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

On Tue, Jun 01, 2004 at 10:22:55AM -0600, Eric Whiting wrote:
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

Linux is a general purpose OS where users have the expecation that
networking behaves in certain ways.  ONTAP drives an appliance whose
purpose is to run file sharing protocols.  This means they can make
network level compromises and optimisations that we can't. 

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
