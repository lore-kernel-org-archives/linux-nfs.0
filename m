From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: high server load when quotas exceeded
Date: Thu, 30 Oct 2003 12:18:07 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1067534286.9355.10.camel@binkley>
References: <vqowuaotjec.fsf@astazou.imag.fr>
	 <vqoznfibu6m.fsf@astazou.imag.fr> <1067530841.9355.6.camel@binkley>
	 <vqoptgeveh8.fsf@astazou.imag.fr>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AFGT4-0000Aa-00
	for <nfs@lists.sourceforge.net>; Thu, 30 Oct 2003 09:20:18 -0800
Received: from mail.phy.duke.edu ([152.3.182.2] ident=[40gGZC2oNByRvUlk5vj5A1AHUtTVRTa5])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AFGT3-0001bH-W0
	for nfs@lists.sourceforge.net; Thu, 30 Oct 2003 09:20:18 -0800
To: Nicolas Kowalski <Nicolas.Kowalski@imag.fr>
In-Reply-To: <vqoptgeveh8.fsf@astazou.imag.fr>
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

On Thu, 2003-10-30 at 12:10, Nicolas Kowalski wrote:
> seth vidal <skvidal@phy.duke.edu> writes:
> 
> >> Anyone? 
> >> What additional information can I provide for debugging this?
> >> 
> >
> > It happens for me too, it's apparently 'expected behavior' so you're
> > kinda out of luck from what I saw in the past.
> 
> Expected? It seems amazing.
> 
> Do you have any pointers to what you saw in the past about this?
> 

it was either on this list or in red hat's bugzilla.

the gist is - there is a return for out of quota space and a different
return for out of diskspace.

your user's program would probably honor the latter but not the former.

-sv




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?   SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
