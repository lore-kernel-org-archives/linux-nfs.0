From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: High Availability NFS Proposal
Date: Mon, 26 Aug 2002 12:54:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020826175418.GB110744@sheplerathome.eng.sun.com>
References: <brugolsky@telemetry-investments.com> <20020825012816.A7902@ti19> <200208260446.g7Q4k6325681@localhost.localdomain>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
        nfs@lists.sourceforge.net, lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nwkea-mail-1.sun.com ([192.18.42.13])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jO5O-0007nO-00
	for <nfs@lists.sourceforge.net>; Mon, 26 Aug 2002 10:55:34 -0700
To: James Bottomley <James.Bottomley@SteelEye.com>
In-Reply-To: <200208260446.g7Q4k6325681@localhost.localdomain>
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

On Sun, James Bottomley wrote:
> > Back in 2.2.x, David Woodhouse wrote code (never merged) that added
> > mountd upcalls to knfsd.  The code was modified by Elvis Pftzenreuter
> > <epx@conectiva.com.br>, then updated by Luis Claudio R. Goncalves
> > <lclaudio@conectiva.com.br>.  IIRC, the original impetus was to handle
> > re-authentication in the presence of wildcard (netgroup, etc.) exports
> > in a sane way.
> 
> > You can find Elvis's original patchset here:
> 
> > http://marc.theaimsgroup.com/?l=linux-nfs&m=87941837303295&w=2
> 
> > Some of Neil Brown's early comments on how to improve and generalize
> > the infrastructure can be found here:
> 
> > http://marc.theaimsgroup.com/?l=linux-nfs&m=87941837303307&w=2 
> 
> Actually, this is exactly what our current HA-NFS patch set (for 2.2. and 2.4) 
> does.  It's available at:
> 
> http://licensing.steeleye.com/open_source/sourcepage.php?prefix=nfs
> 
> but I agree with Linus: If you can do it from user level, there's no need for 
> kernel hooks.  That's essentially the reason I'd like to abandon this approach 
> and go with an entirely user level scheme based on hooks in mount and statd.

How would you propose dealing with NFSv4 where the mount and statd
daemons are not involved with that implementation?

-- 
Spencer



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
