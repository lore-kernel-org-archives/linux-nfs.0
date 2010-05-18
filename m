From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Different options for subdir? Possible?
Date: Tue, 18 May 2010 14:24:28 -0400
Message-ID: <20100518182428.GE20706@fieldses.org>
References: <20100515153104.51f5e4ab@mjolnir.ossman.eu> <20100517204947.GC5232@fieldses.org> <20100518193445.0c8dbc17@mjolnir.ossman.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Pierre Ossman <pierre-list-vCPtPcF4ZGuHXe+LvDLADg@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:32969 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752521Ab0ERSY3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 14:24:29 -0400
In-Reply-To: <20100518193445.0c8dbc17-OhHrUh4vRMS8I+09wXhka4dd74u8MsAO@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 18, 2010 at 07:34:45PM +0200, Pierre Ossman wrote:
> On Mon, 17 May 2010 16:49:47 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Sat, May 15, 2010 at 03:31:04PM +0200, Pierre Ossman wrote:
> > > I'd like to export the filesystem /exports as ro, but the
> > > subdir /exports/dump as rw. I can't seem to get it to work though, so
> > > before I start digging deeper I figured I might ask if this is even
> > > possible? :)
> > 
> > If the "dump" subdirectory is a subdirectory of the same filesystem (not
> > a mountpoint), and if you're using NFSv4 (or v2/v3 with crossmnt), the
> > client will continue to use the export options on the parent directory.
> > 
> 
> Hmm... client? Can't say I'm intimate with the NFS protocol, but access
> permissions like this seems like a server decision.

Yes, apologies for the imprecise language.

> > Also, note that it's relatively easy for someone with access to the
> > network to treat all of /exports as rw.
> 
> Even with subtree check?

If you turn on subtree_check, you're safe.  (That can cause other
problems, though, due to filehandles changing on cross-directory
rename.)

--b.

> > In general, export points that aren't mountpoints are not usually a good
> > idea.
> 
> Fair enough. I'll have to figure something else out.
> 
> Thanks
> -- 
>      -- Pierre Ossman
> 
>   WARNING: This correspondence is being monitored by FRA, a
>   Swedish intelligence agency. Make sure your server uses
>   encryption for SMTP traffic and consider using PGP for
>   end-to-end encryption.


