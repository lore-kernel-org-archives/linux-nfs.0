From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: High Availability NFS Proposal
Date: Mon, 26 Aug 2002 17:01:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020826220136.GB100566@dhcp-uaus08-128-212.sun.com>
References: <20020826175418.GB110744@sheplerathome.eng.sun.com> <200208261904.g7QJ4Gd01843@localhost.localdomain>
Reply-To: spencer.shepler@Sun.COM
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: spencer.shepler@Sun.COM,
        "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
        nfs@lists.sourceforge.net, lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nwkea-mail-1.sun.com ([192.18.42.13])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17jRvn-00038n-00
	for <nfs@lists.sourceforge.net>; Mon, 26 Aug 2002 15:01:55 -0700
To: James Bottomley <James.Bottomley@steeleye.com>
In-Reply-To: <200208261904.g7QJ4Gd01843@localhost.localdomain>
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

On Mon, James Bottomley wrote:
> shepler@eng.sun.com said:
> > How would you propose dealing with NFSv4 where the mount and statd
> > daemons are not involved with that implementation? 
> 
> Distributions are only just starting to use V3.  V4 is so far out as not to 
> need consideration at this time.

My comment was meant to draw out a discussion that with NFSv4 the
user-level hooks will not be available and an in-kernel implementation
would need to be considered.  If the current in-kernel implementation
is moving towards user-level, then future v4 work will need to be redone.

-- 
Spencer



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
