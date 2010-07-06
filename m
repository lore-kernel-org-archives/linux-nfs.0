Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:60738 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754262Ab0GFXXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jul 2010 19:23:35 -0400
Subject: RE: 4.1 client - LAYOUTCOMMIT & close
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Daniel.Muntz@emc.com
Cc: andros@netapp.com, sjoshi@bluearc.com, linux-nfs@vger.kernel.org,
        bhalevy@panasas.com
In-Reply-To: <B9A709F368FAAF4DB4B33870F72A141D010180CB@CORPUSMX30A.corp.emc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
	 <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com>
	 <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>
	 <B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>
	 <0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
	 <B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>
	 <1278448834.16176.5.camel@heimdal.trondhjem.org>
	 <B9A709F368FAAF4DB4B33870F72A141D010180CB@CORPUSMX30A.corp.emc.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 06 Jul 2010 19:23:24 -0400
Message-ID: <1278458604.4728.11.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2010-07-06 at 18:50 -0400, Daniel.Muntz@emc.com wrote:

> As we've discussed before, until a LAYOUTCOMMIT occurs, new data may or
> may not be visible to clients.
> 
> Suppose my server takes the approach that a COMMIT guarantees that data
> is written to a persistent intent log in NVRAM.  On LAYOUTCOMMIT, file
> data is updated from NVRAM and there is a change attribute update
> (atomic).  A client that does not issue LAYOUTCOMMITs will not be able
> to write data.  

That's fine unless you make those updates visible to other clients. It's
a rather expensive way of solving the problem, though.

> If every WRITE to a DS has to atomically update metadata on the MDS,
> perhaps we could improve performance by co-locating data and metadata on
> a single server [1/2 :-)]

You only need to update the metadata when someone requests a change
attribute or mtime through a GETATTR request to the MDS, so it shouldn't
be that difficult to implement.

> > 
> > As I see it, if your server allows one client to read data 
> > that may have
> > been modified by another client that holds a WRITE layout for 
> > that range
> > then (since that is a visible data change) it should provide a change
> > attribute update irrespective of whether or not a 
> > LAYOUTCOMMIT has been
> > sent.
> > If your MDS is incapable of determining whether or not data 
> > has changed
> > on the DSes, then it should probably recall the WRITE layout 
> > if someone
> > tries to read data that may have been modified. Said server 
> > also needs a
> > strategy for determining if a data change occurred if the client that
> > held the WRITE layout died before it could send the LAYOUTCOMMIT.
> 
> Sounds like you're suggesting treating layouts as capabilities in the
> files case, which is one way to solve the problem.  Is anyone doing
> this, or are the files implementations still all treating layouts as
> simply data locators?

You shouldn't need it if you have a control protocol that conforms to
the definition in section 12.2.6.

Cheers
  Trond

> > 
> > Cheers
> >    Trond
> > 
> > > -Dan
> > > 
> > > > -----Original Message-----
> > > > From: Andy Adamson [mailto:andros@netapp.com] 
> > > > Sent: Tuesday, July 06, 2010 6:38 AM
> > > > To: Muntz, Daniel
> > > > Cc: sjoshi@bluearc.com; linux-nfs@vger.kernel.org; 
> > bhalevy@panasas.com
> > > > Subject: Re: 4.1 client - LAYOUTCOMMIT & close
> > > > 
> > > > 
> > > > On Jul 2, 2010, at 5:46 PM, <Daniel.Muntz@emc.com> wrote:
> > > > 
> > > > > By "extremely lame server" I assume you mean any pNFS 
> > server that
> > > > > doesn't have a cluster FS on the back end.
> > > > 
> > > > No, I mean a pNFS file layout type server that depends upon 
> > > > the 'hint'  
> > > > of file size given by LAYOUTCOMMIT. This does not mean 
> > that the file  
> > > > system has to be a cluster FS.
> > > > 
> > > > If COMMIT through MDS is set, the MDS to DS protocol (be it a 
> > > > cluster  
> > > > FS or not) ensures the data is "commited" on the DSs.  
> > > > LAYOUTCOMMIT is  
> > > > not needed.
> > > > 
> > > > If COMMITs are sent to the DSs (or FILE_SYNC writes), then 
> > > > the MDS to  
> > > > DS protocol (be it a cluster FS or not) should kick off a 
> > > > back-end DS  
> > > > to MDS communication to update the file size on the MDS.
> > > > 
> > > > What I consider an 'extremely lame pNFS file layout 
> > server' is one  
> > > > that requires COMMITs to the DS and then depends upon the 
> > > > LAYOUTCOMMIT  
> > > > to communicate the commited data size to the MDS.
> > > > 
> > > > -->Andy
> > > > 
> > > > 
> > > > > So while this might work
> > > > > well for NetApp (as long as NetApp never ships a non-clustered  
> > > > > pNFS), it
> > > > > might break others, or at least severely impact their 
> > > > performance.   
> > > > > For
> > > > > example, will the Solaris pNFS server work correctly without
> > > > > LAYOUTCOMMIT?  IMHO, the client MUST issue the appropriate  
> > > > > LAYOUTCOMMIT,
> > > > > but the server is free to handle it as a no-op if the server
> > > > > implementation does not need to utilize the payload.
> > > > >
> > > > >  -Dan
> > > > >
> > > > >> -----Original Message-----
> > > > >> From: linux-nfs-owner@vger.kernel.org
> > > > >> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of 
> > Andy Adamson
> > > > >> Sent: Friday, July 02, 2010 8:41 AM
> > > > >> To: Sandeep Joshi
> > > > >> Cc: linux-nfs@vger.kernel.org; bhalevy@panasas.com
> > > > >> Subject: Re: 4.1 client - LAYOUTCOMMIT & close
> > > > >>
> > > > >>
> > > > >> On Jul 1, 2010, at 8:07 PM, Sandeep Joshi wrote:
> > > > >>
> > > > >> Hi Sandeep
> > > > >>
> > > > >>>
> > > > >>> In certain cases, I don't see layoutcommit on a file 
> > at all even
> > > > >>> after doing many writes.
> > > > >>
> > > > >> FYI:
> > > > >>
> > > > >> You should not be paying attention to layoutcommits  - 
> > they have no
> > > > >> value for the file layout type.
> > > > >>
> > > > >> From RFC 5661:
> > > > >>
> > > > >> "The LAYOUTCOMMIT operation commits chages in the layout 
> > > > represented
> > > > >> by the current filehandle, client ID (derived from the 
> > > > session ID in
> > > > >> the preceding SEQUENCE operation), byte-range, and stateid."
> > > > >>
> > > > >> For the block layout type, this sentence has meaning in that
> > > > >> there is
> > > > >> a layoutupdate4 payload that enumerates the blocks that 
> > > > have changed
> > > > >> state from being 'handed out' to being 'written'.
> > > > >>
> > > > >> The file layout type has no layoutupdate4 payload, and the
> > > > >> layout does
> > > > >> not change due to writes, and thus the LAYOUTCOMMIT call 
> > > > is useless.
> > > > >>
> > > > >> The only field in the LAYOUTCOMMIT4args that might possibly
> > > > >> be useful
> > > > >> is the loca_last_write_offset which tells the server what 
> > > > the client
> > > > >> thinks is the EOF of the file after WRITE. It is an 
> > extremely lame
> > > > >> server (file layout type server) that depends upon 
> > clients for this
> > > > >> info.
> > > > >>
> > > > >>>
> > > > >>>
> > > > >>>
> > > > >>> Client side operations:
> > > > >>>
> > > > >>> open
> > > > >>> write(s)
> > > > >>> close
> > > > >>>
> > > > >>>
> > > > >>> On server side (observed operations):
> > > > >>>
> > > > >>> open
> > > > >>> layoutget's
> > > > >>> close
> > > > >>>
> > > > >>>
> > > > >>> But, I do not see laycommit at all. In terms data written
> > > > >> by client
> > > > >>> it is about 4-5MB.
> > > > >>>
> > > > >>> When does client issue laycommit?
> > > > >>
> > > > >> The latest linux client sends a layout commit when the 
> > VFS does a
> > > > >> super_operations.write_inode call which happens when the 
> > > > metadata of
> > > > >> an inode needs updating. We are seriously considering 
> > removing the
> > > > >> layoutcommit call from the file layout client.
> > > > >>
> > > > >> -->Andy
> > > > >>
> > > > >>>
> > > > >>>
> > > > >>> regards,
> > > > >>>
> > > > >>> Sandeep
> > > > >>>
> > > > >>> --
> > > > >>> To unsubscribe from this list: send the line "unsubscribe
> > > > >> linux-nfs"
> > > > >>> in
> > > > >>> the body of a message to majordomo@vger.kernel.org
> > > > >>> More majordomo info at  
> > http://vger.kernel.org/majordomo-info.html
> > > > >>
> > > > >> --
> > > > >> To unsubscribe from this list: send the line "unsubscribe
> > > > >> linux-nfs" in
> > > > >> the body of a message to majordomo@vger.kernel.org
> > > > >> More majordomo info at  
> > http://vger.kernel.org/majordomo-info.html
> > > > >>
> > > > >>
> > > > 
> > > > 
> > > > 
> > > --
> > > To unsubscribe from this list: send the line "unsubscribe 
> > linux-nfs" in
> > > the body of a message to majordomo@vger.kernel.org
> > > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> > 
> > 
> > 
> > 
> > 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html



