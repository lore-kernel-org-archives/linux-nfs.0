Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:40798 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753541Ab0GFTUu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jul 2010 15:20:50 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: 4.1 client - LAYOUTCOMMIT & close
Date: Tue, 6 Jul 2010 15:20:08 -0400
Message-ID: <B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>
In-Reply-To: <0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com> <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com> <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com> <B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com> <0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
From: <Daniel.Muntz@emc.com>
To: <andros@netapp.com>
Cc: <sjoshi@bluearc.com>, <linux-nfs@vger.kernel.org>, <bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The COMMIT to the DS, ttbomk, commits data on the DS.  I see it as
orthogonal to updating the metadata on the MDS (but perhaps I'm wrong).
As sjoshi@bluearc mentioned, the LAYOUTCOMMIT provides a synchronization
point, so even if the non-clustered server does not want to update
metadata on every DS I/O, the LAYOUTCOMMIT could also be a trigger to
execute whatever synchronization mechanism the implementer wishes to put
in the control protocol.

  -Dan

> -----Original Message-----
> From: Andy Adamson [mailto:andros@netapp.com] 
> Sent: Tuesday, July 06, 2010 6:38 AM
> To: Muntz, Daniel
> Cc: sjoshi@bluearc.com; linux-nfs@vger.kernel.org; bhalevy@panasas.com
> Subject: Re: 4.1 client - LAYOUTCOMMIT & close
> 
> 
> On Jul 2, 2010, at 5:46 PM, <Daniel.Muntz@emc.com> wrote:
> 
> > By "extremely lame server" I assume you mean any pNFS server that
> > doesn't have a cluster FS on the back end.
> 
> No, I mean a pNFS file layout type server that depends upon 
> the 'hint'  
> of file size given by LAYOUTCOMMIT. This does not mean that the file  
> system has to be a cluster FS.
> 
> If COMMIT through MDS is set, the MDS to DS protocol (be it a 
> cluster  
> FS or not) ensures the data is "commited" on the DSs.  
> LAYOUTCOMMIT is  
> not needed.
> 
> If COMMITs are sent to the DSs (or FILE_SYNC writes), then 
> the MDS to  
> DS protocol (be it a cluster FS or not) should kick off a 
> back-end DS  
> to MDS communication to update the file size on the MDS.
> 
> What I consider an 'extremely lame pNFS file layout server' is one  
> that requires COMMITs to the DS and then depends upon the 
> LAYOUTCOMMIT  
> to communicate the commited data size to the MDS.
> 
> -->Andy
> 
> 
> > So while this might work
> > well for NetApp (as long as NetApp never ships a non-clustered  
> > pNFS), it
> > might break others, or at least severely impact their 
> performance.   
> > For
> > example, will the Solaris pNFS server work correctly without
> > LAYOUTCOMMIT?  IMHO, the client MUST issue the appropriate  
> > LAYOUTCOMMIT,
> > but the server is free to handle it as a no-op if the server
> > implementation does not need to utilize the payload.
> >
> >  -Dan
> >
> >> -----Original Message-----
> >> From: linux-nfs-owner@vger.kernel.org
> >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Andy Adamson
> >> Sent: Friday, July 02, 2010 8:41 AM
> >> To: Sandeep Joshi
> >> Cc: linux-nfs@vger.kernel.org; bhalevy@panasas.com
> >> Subject: Re: 4.1 client - LAYOUTCOMMIT & close
> >>
> >>
> >> On Jul 1, 2010, at 8:07 PM, Sandeep Joshi wrote:
> >>
> >> Hi Sandeep
> >>
> >>>
> >>> In certain cases, I don't see layoutcommit on a file at all even
> >>> after doing many writes.
> >>
> >> FYI:
> >>
> >> You should not be paying attention to layoutcommits  - they have no
> >> value for the file layout type.
> >>
> >> From RFC 5661:
> >>
> >> "The LAYOUTCOMMIT operation commits chages in the layout 
> represented
> >> by the current filehandle, client ID (derived from the 
> session ID in
> >> the preceding SEQUENCE operation), byte-range, and stateid."
> >>
> >> For the block layout type, this sentence has meaning in that
> >> there is
> >> a layoutupdate4 payload that enumerates the blocks that 
> have changed
> >> state from being 'handed out' to being 'written'.
> >>
> >> The file layout type has no layoutupdate4 payload, and the
> >> layout does
> >> not change due to writes, and thus the LAYOUTCOMMIT call 
> is useless.
> >>
> >> The only field in the LAYOUTCOMMIT4args that might possibly
> >> be useful
> >> is the loca_last_write_offset which tells the server what 
> the client
> >> thinks is the EOF of the file after WRITE. It is an extremely lame
> >> server (file layout type server) that depends upon clients for this
> >> info.
> >>
> >>>
> >>>
> >>>
> >>> Client side operations:
> >>>
> >>> open
> >>> write(s)
> >>> close
> >>>
> >>>
> >>> On server side (observed operations):
> >>>
> >>> open
> >>> layoutget's
> >>> close
> >>>
> >>>
> >>> But, I do not see laycommit at all. In terms data written
> >> by client
> >>> it is about 4-5MB.
> >>>
> >>> When does client issue laycommit?
> >>
> >> The latest linux client sends a layout commit when the VFS does a
> >> super_operations.write_inode call which happens when the 
> metadata of
> >> an inode needs updating. We are seriously considering removing the
> >> layoutcommit call from the file layout client.
> >>
> >> -->Andy
> >>
> >>>
> >>>
> >>> regards,
> >>>
> >>> Sandeep
> >>>
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe
> >> linux-nfs"
> >>> in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe
> >> linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>
> >>
> 
> 
> 
