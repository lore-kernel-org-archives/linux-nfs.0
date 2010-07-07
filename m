Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:53759 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754192Ab0GGNGm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 09:06:42 -0400
Subject: Re: 4.1 client - LAYOUTCOMMIT & close
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Daniel.Muntz@emc.com, andros@netapp.com, sjoshi@bluearc.com,
        linux-nfs@vger.kernel.org, NFSv4 <nfsv4@ietf.org>
In-Reply-To: <4C346D80.8010405@panasas.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
	 <A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com>
	 <6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>
	 <B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>
	 <0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
	 <B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>
	 <1278448834.16176.5.camel@heimdal.trondhjem.org>
	 <4C346D80.8010405@panasas.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 07 Jul 2010 09:06:25 -0400
Message-ID: <1278507985.2804.30.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-07-07 at 15:05 +0300, Benny Halevy wrote:
> On Jul. 06, 2010, 23:40 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2010-07-06 at 15:20 -0400, Daniel.Muntz@emc.com wrote: 
> >> The COMMIT to the DS, ttbomk, commits data on the DS.  I see it as
> >> orthogonal to updating the metadata on the MDS (but perhaps I'm wrong).
> >> As sjoshi@bluearc mentioned, the LAYOUTCOMMIT provides a synchronization
> >> point, so even if the non-clustered server does not want to update
> >> metadata on every DS I/O, the LAYOUTCOMMIT could also be a trigger to
> >> execute whatever synchronization mechanism the implementer wishes to put
> >> in the control protocol.
> > 
> > As far as I'm aware, there are no exceptions in RFC5661 that would allow
> > pNFS servers to break the rule that any visible change to the data must
> > be atomically accompanied with a change attribute update.
> > 
> 
> Trond, I'm not sure how this rule you mentioned is specified.
> 
> See more in section 12.5.4 and 12.5.4.1. LAYOUTCOMMIT and change/time_modify
> in particular:
> 
>    For some layout protocols, the storage device is able to notify the
>    metadata server of the occurrence of an I/O; as a result, the change
>    and time_modify attributes may be updated at the metadata server.
>    For a metadata server that is capable of monitoring updates to the
>    change and time_modify attributes, LAYOUTCOMMIT processing is not
>    required to update the change attribute.  In this case, the metadata
>    server must ensure that no further update to the data has occurred
>    since the last update of the attributes; file-based protocols may
>    have enough information to make this determination or may update the
>    change attribute upon each file modification.  This also applies for
>    the time_modify attribute.  If the server implementation is able to
>    determine that the file has not been modified since the last
>    time_modify update, the server need not update time_modify at
>    LAYOUTCOMMIT.  At LAYOUTCOMMIT completion, the updated attributes
>    should be visible if that file was modified since the latest previous
>    LAYOUTCOMMIT or LAYOUTGET

I know. However the above paragraph does not state that the server
should make those changes visible to clients other than the one that is
writing.

Section 18.32.4 states that writes will cause the time_modified and
change attributes to be updated (if and only if the file data is
modified). Several other sections rely on this behaviour, including
section 10.3.1, section 11.7.2.2, and section 11.7.7.

The only 'special behaviour' that I see allowed for pNFS is in section
13.10, which states that clients can't expect to see changes
immediately, but that they must be able to expect close-to-open
semantics to work. Again, if this is to be the case, then the server
_must_ be able to deal with the case where client 1 dies before it can
issue the LAYOUTCOMMIT.


> > As I see it, if your server allows one client to read data that may have
> > been modified by another client that holds a WRITE layout for that range
> > then (since that is a visible data change) it should provide a change
> > attribute update irrespective of whether or not a LAYOUTCOMMIT has been
> > sent.
> 
> the requirement for the server in WRITE's implementation section 
> is quite weak: "It is assumed that the act of writing data to a file will
> cause the time_modified and change attributes of the file to be updated."
> 
> The difference here is that for pNFS the written data is not guaranteed
> to be visible until LAYOUTCOMMIT.  In a broader sense, assuming the clients
> are caching dirty data and use a write-behind cache, application-written data
> may be visible to other processes on the same host but not to others until
> fsync() or close() - open-to-close semantics are the only thing the client
> guarantees, right?  Issuing LAYOUTCOMMIT on fsync() and close() ensure the
> data is committed to stable storage and is visible to all other clients in
> the cluster.

See above. I'm not disputing your statement that 'the written data is
not guaranteed to be visible until LAYOUTCOMMIT'. I am disputing an
assumption that 'the written data may be visible without an accompanying
change attribute update'.

Trond

> Benny
> 
> > If your MDS is incapable of determining whether or not data has changed
> > on the DSes, then it should probably recall the WRITE layout if someone
> > tries to read data that may have been modified. Said server also needs a
> > strategy for determining if a data change occurred if the client that
> > held the WRITE layout died before it could send the LAYOUTCOMMIT.
> > 
> > Cheers
> >    Trond
> > 
> >> -Dan
> >>
> >>> -----Original Message-----
> >>> From: Andy Adamson [mailto:andros@netapp.com] 
> >>> Sent: Tuesday, July 06, 2010 6:38 AM
> >>> To: Muntz, Daniel
> >>> Cc: sjoshi@bluearc.com; linux-nfs@vger.kernel.org; bhalevy@panasas.com
> >>> Subject: Re: 4.1 client - LAYOUTCOMMIT & close
> >>>
> >>>
> >>> On Jul 2, 2010, at 5:46 PM, <Daniel.Muntz@emc.com> wrote:
> >>>
> >>>> By "extremely lame server" I assume you mean any pNFS server that
> >>>> doesn't have a cluster FS on the back end.
> >>>
> >>> No, I mean a pNFS file layout type server that depends upon 
> >>> the 'hint'  
> >>> of file size given by LAYOUTCOMMIT. This does not mean that the file  
> >>> system has to be a cluster FS.
> >>>
> >>> If COMMIT through MDS is set, the MDS to DS protocol (be it a 
> >>> cluster  
> >>> FS or not) ensures the data is "commited" on the DSs.  
> >>> LAYOUTCOMMIT is  
> >>> not needed.
> >>>
> >>> If COMMITs are sent to the DSs (or FILE_SYNC writes), then 
> >>> the MDS to  
> >>> DS protocol (be it a cluster FS or not) should kick off a 
> >>> back-end DS  
> >>> to MDS communication to update the file size on the MDS.
> >>>
> >>> What I consider an 'extremely lame pNFS file layout server' is one  
> >>> that requires COMMITs to the DS and then depends upon the 
> >>> LAYOUTCOMMIT  
> >>> to communicate the commited data size to the MDS.
> >>>
> >>> -->Andy
> >>>
> >>>
> >>>> So while this might work
> >>>> well for NetApp (as long as NetApp never ships a non-clustered  
> >>>> pNFS), it
> >>>> might break others, or at least severely impact their 
> >>> performance.   
> >>>> For
> >>>> example, will the Solaris pNFS server work correctly without
> >>>> LAYOUTCOMMIT?  IMHO, the client MUST issue the appropriate  
> >>>> LAYOUTCOMMIT,
> >>>> but the server is free to handle it as a no-op if the server
> >>>> implementation does not need to utilize the payload.
> >>>>
> >>>>  -Dan
> >>>>
> >>>>> -----Original Message-----
> >>>>> From: linux-nfs-owner@vger.kernel.org
> >>>>> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Andy Adamson
> >>>>> Sent: Friday, July 02, 2010 8:41 AM
> >>>>> To: Sandeep Joshi
> >>>>> Cc: linux-nfs@vger.kernel.org; bhalevy@panasas.com
> >>>>> Subject: Re: 4.1 client - LAYOUTCOMMIT & close
> >>>>>
> >>>>>
> >>>>> On Jul 1, 2010, at 8:07 PM, Sandeep Joshi wrote:
> >>>>>
> >>>>> Hi Sandeep
> >>>>>
> >>>>>>
> >>>>>> In certain cases, I don't see layoutcommit on a file at all even
> >>>>>> after doing many writes.
> >>>>>
> >>>>> FYI:
> >>>>>
> >>>>> You should not be paying attention to layoutcommits  - they have no
> >>>>> value for the file layout type.
> >>>>>
> >>>>> From RFC 5661:
> >>>>>
> >>>>> "The LAYOUTCOMMIT operation commits chages in the layout 
> >>> represented
> >>>>> by the current filehandle, client ID (derived from the 
> >>> session ID in
> >>>>> the preceding SEQUENCE operation), byte-range, and stateid."
> >>>>>
> >>>>> For the block layout type, this sentence has meaning in that
> >>>>> there is
> >>>>> a layoutupdate4 payload that enumerates the blocks that 
> >>> have changed
> >>>>> state from being 'handed out' to being 'written'.
> >>>>>
> >>>>> The file layout type has no layoutupdate4 payload, and the
> >>>>> layout does
> >>>>> not change due to writes, and thus the LAYOUTCOMMIT call 
> >>> is useless.
> >>>>>
> >>>>> The only field in the LAYOUTCOMMIT4args that might possibly
> >>>>> be useful
> >>>>> is the loca_last_write_offset which tells the server what 
> >>> the client
> >>>>> thinks is the EOF of the file after WRITE. It is an extremely lame
> >>>>> server (file layout type server) that depends upon clients for this
> >>>>> info.
> >>>>>
> >>>>>>
> >>>>>>
> >>>>>>
> >>>>>> Client side operations:
> >>>>>>
> >>>>>> open
> >>>>>> write(s)
> >>>>>> close
> >>>>>>
> >>>>>>
> >>>>>> On server side (observed operations):
> >>>>>>
> >>>>>> open
> >>>>>> layoutget's
> >>>>>> close
> >>>>>>
> >>>>>>
> >>>>>> But, I do not see laycommit at all. In terms data written
> >>>>> by client
> >>>>>> it is about 4-5MB.
> >>>>>>
> >>>>>> When does client issue laycommit?
> >>>>>
> >>>>> The latest linux client sends a layout commit when the VFS does a
> >>>>> super_operations.write_inode call which happens when the 
> >>> metadata of
> >>>>> an inode needs updating. We are seriously considering removing the
> >>>>> layoutcommit call from the file layout client.
> >>>>>
> >>>>> -->Andy
> >>>>>
> >>>>>>
> >>>>>>
> >>>>>> regards,
> >>>>>>
> >>>>>> Sandeep
> >>>>>>
> >>>>>> --
> >>>>>> To unsubscribe from this list: send the line "unsubscribe
> >>>>> linux-nfs"
> >>>>>> in
> >>>>>> the body of a message to majordomo@vger.kernel.org
> >>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>>>
> >>>>> --
> >>>>> To unsubscribe from this list: send the line "unsubscribe
> >>>>> linux-nfs" in
> >>>>> the body of a message to majordomo@vger.kernel.org
> >>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >>>>>
> >>>>>
> >>>
> >>>
> >>>
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
> > 
> > 
> > 
> > 



