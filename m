From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Fri, 23 Apr 2004 20:50:28 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040423185028.GA15770@suse.de>
References: <40892507.2030004@RedHat.com> <20040423143308.GW3491@suse.de> <40893B51.2080302@RedHat.com> <20040423175552.GA13755@suse.de> <408963E0.9070001@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BH5ks-0004vH-Tl
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 11:50:30 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BH5ks-0004WT-Be
	for nfs@lists.sourceforge.net; Fri, 23 Apr 2004 11:50:30 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <408963E0.9070001@RedHat.com>
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

On Fri, Apr 23, 2004 at 02:43:44PM -0400, Steve Dickson wrote:
> >What will get you into trouble is if your client writes
> >to "foo" and you do a "mv bar foo".
> > 
> >
> This also seem to work... I figured since foo was open it
> got renamed to .nfs file until the first write was finished...

It will, as long as the mv is executed on the NFS client
where your writing process runs. But in the particular case
that prompted you do create that patch, rsync ran on the
NFS server, didn't it?

Olaf
-- 
Olaf Kirch     |  The Hardware Gods hate me.
okir@suse.de   |
---------------+ 


-------------------------------------------------------
This SF.net email is sponsored by: The Robotic Monkeys at ThinkGeek
For a limited time only, get FREE Ground shipping on all orders of $35
or more. Hurry up and shop folks, this offer expires April 30th!
http://www.thinkgeek.com/freeshipping/?cpg=12297
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
