From: Spencer Shepler <shepler@eng.sun.com>
Subject: Re: NFS mount option - noac forces sync even if async is sp ecified, and no warning is given
Date: Wed, 5 Feb 2003 16:40:15 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030205224015.GA102862@dhcp-uaus08-128-228.sun.com>
References: <6440EA1A6AA1D5118C6900902745938E07D552A3@black.eng.netapp.com>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'Heflin, Roger A.'" <Roger.A.Heflin@conocophillips.com>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pheriche.sun.com ([192.18.98.34])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18gYFZ-0000FC-00
	for <nfs@lists.sourceforge.net>; Wed, 05 Feb 2003 14:42:37 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D552A3@black.eng.netapp.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Wed, Lever, Charles wrote:
> > > ah, but Solaris noac doesn't disable *data* caching.  data is still
> > > cached until the client detects the file has changed.  *writes* are
> > > no longer cached, but reads can hit the client's data cache as long
> > > as the file doesn't change on the server.
> > > 
> > 	Then their manpage is also wrong.  On 2.6 (and 2.8) it says:
> > 	         noac           Suppress data and attribute caching.
> > 
> > 	It sounds very much like they kill all caching, but who knows
> > 	what they actually do.
> 
> for the record, here's what my man page says (Solaris 9):
> 
>      noac    Suppress data and attribute caching.  The data
>              caching that is suppressed is the write-behind.
>              The local page cache is still maintained, but
>              data copied into it is immediately written to
>              the server.
> 
> there's a section further down in the man page called "File
> Attributes" that explains in detail how attribute caching
> works and what noac does, which i think also appears in the
> Solaris 8 version of this page.

Correct.  The additional explanation is contained in the Solaris 8 man
page.

-- 
Spencer



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
