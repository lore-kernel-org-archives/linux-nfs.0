From: <Daniel.Muntz@emc.com>
Subject: Re: 4.1 client - LAYOUTCOMMIT & close
Date: Thu, 8 Jul 2010 19:51:47 -0400
Message-ID: <B9A709F368FAAF4DB4B33870F72A141D0106C172@CORPUSMX30A.corp.emc.com>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
	<6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>
	<B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>
	<0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
	<B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>
	<1278448834.16176.5.camel@heimdal.trondhjem.org>
	<4C346D80.8010405@panasas.com>
	<1278507985.2804.30.camel@heimdal.trondhjem.org>
	<1278508696.2804.35.camel@heimdal.trondhjem.org>
	<4C348679.6010507@panasas.com>
	<1278511416.2804.52.camel@heimdal.trondhjem.org>
	<B9A709F368FAAF4DB4B33870F72A141D0106B6B0@CORPUSMX30A.corp.emc.com>
	<1278536484.12889.4.camel@heimdal.trondhjem.org>
	<BF3BB6D12298F54B89C8DCC1E4073D8001ADDDA5@CORPUSMX50A.corp.emc.com>
	<C2D311A6F086424F99E385949ECFEBCB030F2A80@CORPUSMX80B.corp.emc.com>
	<1278543175.15524.2.camel@heimdal.trondhjem.org>
	<1278544149.15524.15.camel@heimdal.trondhjem.org>
	<1278544497.15524.17.camel@heimdal.trondhje! m .org> < 4C35!
	F5E3.3000 604@panasas. com>
	<C2D311A6F086424F99E385949ECFEBCB030F2EBF@CORPUSMX80B.corp.emc.com>
	<1278623771.13551.54.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, garth@panasas.com, welch@panasas.com,
	nfsv4@ietf.org, andros@netapp.com, bhalevy@panasas.com
To: <trond.myklebust@fys.uio.no>, <david.black@emc.com>
Return-path: <nfsv4-bounces@ietf.org>
In-Reply-To: <1278623771.13551.54.camel@heimdal.trondhjem.org>
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: linux-nfs-owner@vger.kernel.org 
> [mailto:linux-nfs-owner@vger.kernel.org] On Behalf Of Trond Myklebust
> Sent: Thursday, July 08, 2010 2:16 PM
> To: Black, David
> Cc: bhalevy@panasas.com; linux-nfs@vger.kernel.org; 
> garth@panasas.com; welch@panasas.com; nfsv4@ietf.org; 
> andros@netapp.com
> Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
> 
> On Thu, 2010-07-08 at 16:30 -0400, david.black@emc.com wrote:
> > > Note that a LAYOUTRETURN can arrive without LAYOUTCOMMIT 
> if the client hasn't
> > > written to the file.  I'm not sure what about the blocks 
> case though, do you
> > > implicitly free up any provisionally allocated blocks 
> that the client had not
> > > explicitly committed using LAYOUTCOMMIT?
> > 
> > In principle, yes as the blocks are no longer promised to 
> the client, although
> > lazy evaluation of this is an obvious optimization.
> > 
> > > >> "Upon receiving an OPEN, LOCK or a WANT_DELEGATION, 
> the server must
> > > >> check that it has received LAYOUTCOMMITs from any 
> other clients that may
> > > >> have the file open for writing. If it hasn't, then it 
> MUST take some
> > > >> action to ensure that any file data changes are 
> accompanied by a change
> > > >                            ^ potentially visible
> > > >> attribute update."
> > > 
> > > That should be OK as long as it's not for every GETATTR 
> for the change, mtime,
> > > or size attributes.
> > > 
> > > >>
> > > >> Then you can add the above suggestion without the 
> offending caveat. Note
> > > >> however that it does break the "SHOULD NOT" admonition 
> in section
> > > >> 18.32.4.
> > > 
> > > Better be safe than sorry in this rare error case.
> > 
> > I concur with Benny on both of the above - in essence, the 
> unrecovered client failure is a reason to potentially ignore 
> the "SHOULD" (server can't know whether it actually ignored 
> the "SHOULD", hence better safe than sorry).  We probably 
> ought to find a someplace appropriate to add a paragraph or 
> two explaining this in one of the 4.2 documents.
> 
> Right. I'm only interested in fixing the close-to-open case. 
> The case of
> general GETATTR calls might be nice to fix too, but it should not be
> essential in order to ensure that well-behaved applications 
> continue to
> work as expected.

I think we have close-to-open covered.  A client will do a LAYOUTCOMMIT
after the last WRITE before a CLOSE (otherwise it has no guarantee that
the data becomes "visible").  So, written data may be "visible" to other
clients without the change attribute being updated, *but* at CLOSE time
we are guaranteed the change attribute is updated.

In the failure case (client dies before sending LAYOUTCOMMIT and/or
CLOSE), the server will eventually have to close the file.  At this
point, the server can, e.g., use its knowledge of the layout(s) that may
have been used by the client to check DSs (via control protocol) to
synthesize the appropriate attributes including change attribute and set
them before completing the server close operation.  This is hand-wavy,
but I think there's a way to solve close-to-open without updating the
change attribute with every DS write.

However, I think we may still have a problem when locking/delegations
are combined with client caching and attempting to decouple the DS write
from the change attribute update.  I'm still looking into this.

> 
> Note, however, that legacy support for stateless protocols like NFSv2
> and NFSv3 may be problematic: there is no equivalent of OPEN, 
> and so the
> server may have to do the above check on all NFSPROC2_GETATTR,
> NFSPROC3_GETATTR, NFSPROC2_LOOKUP and NFSPROC3_LOOKUP requests.
> 
>    Trond
> 
> > Thanks,
> > --David
> > 
> > 
> > > -----Original Message-----
> > > From: Benny Halevy [mailto:bhalevy.lists@gmail.com] On 
> Behalf Of Benny Halevy
> > > Sent: Thursday, July 08, 2010 12:00 PM
> > > To: Trond Myklebust
> > > Cc: Black, David; Noveck, David; Muntz, Daniel; 
> linux-nfs@vger.kernel.org; garth@panasas.com;
> > > welch@panasas.com; nfsv4@ietf.org; andros@netapp.com
> > > Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
> > > 
> > > On Jul. 08, 2010, 2:14 +0300, Trond Myklebust 
> <trond.myklebust@fys.uio.no> wrote:
> > > > On Wed, 2010-07-07 at 19:09 -0400, Trond Myklebust wrote:
> > > >> On Wed, 2010-07-07 at 18:52 -0400, Trond Myklebust wrote:
> > > >>> On Wed, 2010-07-07 at 18:44 -0400, david.black@emc.com wrote:
> > > >>>> Let me try this ...
> > > >>>>
> > > >>>> A correct client will always send LAYOUTCOMMIT.
> > > >>>> Assume that the client is correct.
> > > >>>> Hence if the LAYOUTCOMMIT doesn't arrive, something's failed.
> > > >>>>
> > > >>>> Important implication: No LAYOUTCOMMIT is an 
> error/failure case.  It
> > > >>>> just has to work; it doesn't have to be fast.
> > > >>>>
> > > 
> > > Note that a LAYOUTRETURN can arrive without LAYOUTCOMMIT 
> if the client hasn't
> > > written to the file.  I'm not sure what about the blocks 
> case though, do you
> > > implicitly free up any provisionally allocated blocks 
> that the client had not
> > > explicitly committed using LAYOUTCOMMIT?
> > > 
> > > >>>> Suggestion: If a client dies while holding writeable 
> layouts that permit
> > > >>>> write-in-place, and the client doesn't reappear or 
> doesn't reclaim those
> > > >>>> layouts, then the server should assume that the 
> files involved were
> > > >>>> written before the client died, and set the file 
> attributes accordingly
> > > >>>> as part of internally reclaiming the layout that the 
> client has
> > > >>>> abandoned.
> > > 
> > > Of course. That's part of the server recovery.
> > > 
> > > >>>>
> > > >>>> Caveat: It may take a while for the server to 
> determine that the client
> > > >>>> has abandoned a layout.
> > > 
> > > That's two lease times after a respective CB_LAYOUTRECALL.
> > > 
> > > >>>>
> > > >>>> This can result in false positives (file appears to 
> be modified when it
> > > >>>> wasn't) but won't yield false negatives (file does 
> not appear to be
> > > >>>> modified even though it was modified).
> > > >>>
> > > >>> OK... So we're going to have to turn off client side 
> file caching
> > > >>> entirely for pNFS? I can do that...
> > > >>>
> > > >>> The above won't work. Think readahead...
> > > >>
> > > >> So... What can work, is if you modify it to work explicitly for
> > > >> close-to-open
> > > >>
> > > >> "Upon receiving an OPEN, LOCK or a WANT_DELEGATION, 
> the server must
> > > >> check that it has received LAYOUTCOMMITs from any 
> other clients that may
> > > >> have the file open for writing. If it hasn't, then it 
> MUST take some
> > > >> action to ensure that any file data changes are 
> accompanied by a change
> > > >                            ^ potentially visible
> > > >> attribute update."
> > > 
> > > That should be OK as long as it's not for every GETATTR 
> for the change, mtime,
> > > or size attributes.
> > > 
> > > >>
> > > >> Then you can add the above suggestion without the 
> offending caveat. Note
> > > >> however that it does break the "SHOULD NOT" admonition 
> in section
> > > >> 18.32.4.
> > > 
> > > Better be safe than sorry in this rare error case.
> > > 
> > > Benny
> > > 
> > > >>
> > > >> Trond
> > > >>
> > > >>
> > > >>> Trond
> > > >>>
> > > >>>> Thanks,
> > > >>>> --David
> > > >>>>
> > > >>>>> -----Original Message-----
> > > >>>>> From: nfsv4-bounces@ietf.org 
> [mailto:nfsv4-bounces@ietf.org] On Behalf
> > > >>>> Of Noveck_David@emc.com
> > > >>>>> Sent: Wednesday, July 07, 2010 6:04 PM
> > > >>>>> To: Trond.Myklebust@netapp.com; Muntz, Daniel
> > > >>>>> Cc: linux-nfs@vger.kernel.org; garth@panasas.com; 
> welch@panasas.com;
> > > >>>> nfsv4@ietf.org;
> > > >>>>> andros@netapp.com; bhalevy@panasas.com
> > > >>>>> Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
> > > >>>>>
> > > >>>>>> Yes. I would agree that the client cannot rely on 
> the updates being
> > > >>>> made
> > > >>>>>> visible if it fails to send the LAYOUTCOMMIT. My 
> point was simply
> > > >>>> that a
> > > >>>>>> compliant server MUST also have a valid strategy 
> for dealing with
> > > >>>> the
> > > >>>>>> case where the client doesn't send it.
> > > >>>>>
> > > >>>>> So you are saying the updates "MUST be made 
> visible" through the
> > > >>>>> server's valid strategy.  Is that right.
> > > >>>>>
> > > >>>>> And that the client cannot rely on that.  Why not, 
> if the server must
> > > >>>>> have a valid strategy.
> > > >>>>>
> > > >>>>> Is this just prudent "belt and suspenders" design or what?
> > > >>>>>
> > > >>>>> It seems to me that if one side here is MUST (and 
> the spec needs to be
> > > >>>>> clearer about what might or might not constitute a 
> valid strategy),
> > > >>>> then
> > > >>>>> the other side should be SHOULD.
> > > >>>>>
> > > >>>>> If both sides are "MUST", then if things don't work 
> out then the
> > > >>>> client
> > > >>>>> and server can equally point to one another and say 
> "It's his fault".
> > > >>>>>
> > > >>>>> Am I missing something here?
> > > >>>>>
> > > >>>>>
> > > >>>>>
> > > >>>>> -----Original Message-----
> > > >>>>> From: nfsv4-bounces@ietf.org 
> [mailto:nfsv4-bounces@ietf.org] On Behalf
> > > >>>>> Of Trond Myklebust
> > > >>>>> Sent: Wednesday, July 07, 2010 5:01 PM
> > > >>>>> To: Muntz, Daniel
> > > >>>>> Cc: linux-nfs@vger.kernel.org; garth@panasas.com; 
> welch@panasas.com;
> > > >>>>> nfsv4@ietf.org; andros@netapp.com; bhalevy@panasas.com
> > > >>>>> Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
> > > >>>>>
> > > >>>>> On Wed, 2010-07-07 at 16:39 -0400, 
> Daniel.Muntz@emc.com wrote:
> > > >>>>>> To bring this discussion full circle, since we agree that a
> > > >>>> compliant
> > > >>>>>> server can implement a scheme where written data 
> does not become
> > > >>>>> visible
> > > >>>>>> until after a LAYOUTCOMMIT, do we also agree that 
> LAYOUTCOMMIT is a
> > > >>>>>> "MUST" from a compliant client (independent of 
> layout type)?
> > > >>>>>
> > > >>>>> Yes. I would agree that the client cannot rely on 
> the updates being
> > > >>>> made
> > > >>>>> visible if it fails to send the LAYOUTCOMMIT. My 
> point was simply that
> > > >>>> a
> > > >>>>> compliant server MUST also have a valid strategy 
> for dealing with the
> > > >>>>> case where the client doesn't send it.
> > > >>>>>
> > > >>>>> Cheers
> > > >>>>>   Trond
> > > >>>>>
> > > >>>>>>   -Dan
> > > >>>>>>
> > > >>>>>>> -----Original Message-----
> > > >>>>>>> From: nfsv4-bounces@ietf.org 
> [mailto:nfsv4-bounces@ietf.org]
> > > >>>>>>> On Behalf Of Trond Myklebust
> > > >>>>>>> Sent: Wednesday, July 07, 2010 7:04 AM
> > > >>>>>>> To: Benny Halevy
> > > >>>>>>> Cc: andros@netapp.com; linux-nfs@vger.kernel.org; Garth
> > > >>>>>>> Gibson; Brent Welch; NFSv4
> > > >>>>>>> Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
> > > >>>>>>>
> > > >>>>>>> On Wed, 2010-07-07 at 16:51 +0300, Benny Halevy wrote:
> > > >>>>>>>> On Jul. 07, 2010, 16:18 +0300, Trond Myklebust
> > > >>>>>>> <Trond.Myklebust@netapp.com> wrote:
> > > >>>>>>>>> On Wed, 2010-07-07 at 09:06 -0400, Trond 
> Myklebust wrote:
> > > >>>>>>>>>> On Wed, 2010-07-07 at 15:05 +0300, Benny Halevy wrote:
> > > >>>>>>>>>>> On Jul. 06, 2010, 23:40 +0300, Trond Myklebust
> > > >>>>>>> <trond.myklebust@fys.uio.no> wrote:
> > > >>>>>>>>>>>> On Tue, 2010-07-06 at 15:20 -0400, 
> Daniel.Muntz@emc.com
> > > >>>>> wrote:
> > > >>>>>>>>>>>>> The COMMIT to the DS, ttbomk, commits data 
> on the DS. I
> > > >>>> see it as
> > > >>>>>>>>>>>>> orthogonal to updating the metadata on the MDS (but
> > > >>>> perhaps I'm wrong).
> > > >>>>>>>>>>>>> As sjoshi@bluearc mentioned, the 
> LAYOUTCOMMIT provides a
> > > >>>> synchronization
> > > >>>>>>>>>>>>> point, so even if the non-clustered server 
> does not want
> > > >>>> to update
> > > >>>>>>>>>>>>> metadata on every DS I/O, the LAYOUTCOMMIT 
> could also be a
> > > >>>> trigger to
> > > >>>>>>>>>>>>> execute whatever synchronization mechanism 
> the implementer
> > > >>>> wishes to put
> > > >>>>>>>>>>>>> in the control protocol.
> > > >>>>>>>>>>>>
> > > >>>>>>>>>>>> As far as I'm aware, there are no exceptions 
> in RFC5661
> > > >>>> that would allow
> > > >>>>>>>>>>>> pNFS servers to break the rule that any 
> visible change to
> > > >>>> the data must
> > > >>>>>>>>>>>> be atomically accompanied with a change 
> attribute update.
> > > >>>>>>>>>>>>
> > > >>>>>>>>>>>
> > > >>>>>>>>>>> Trond, I'm not sure how this rule you mentioned is
> > > >>>> specified.
> > > >>>>>>>>>>>
> > > >>>>>>>>>>> See more in section 12.5.4 and 12.5.4.1. 
> LAYOUTCOMMIT and
> > > >>>> change/time_modify
> > > >>>>>>>>>>> in particular:
> > > >>>>>>>>>>>
> > > >>>>>>>>>>>    For some layout protocols, the storage 
> device is able to
> > > >>>> notify the
> > > >>>>>>>>>>>    metadata server of the occurrence of an 
> I/O; as a result,
> > > >>>> the change
> > > >>>>>>>>>>>    and time_modify attributes may be updated 
> at the metadata
> > > >>>> server.
> > > >>>>>>>>>>>    For a metadata server that is capable of monitoring
> > > >>>> updates to the
> > > >>>>>>>>>>>    change and time_modify attributes, LAYOUTCOMMIT
> > > >>>> processing is not
> > > >>>>>>>>>>>    required to update the change attribute.  
> In this case,
> > > >>>> the metadata
> > > >>>>>>>>>>>    server must ensure that no further update 
> to the data has
> > > >>>> occurred
> > > >>>>>>>>>>>    since the last update of the attributes; file-based
> > > >>>> protocols may
> > > >>>>>>>>>>>    have enough information to make this 
> determination or may
> > > >>>> update the
> > > >>>>>>>>>>>    change attribute upon each file 
> modification.  This also
> > > >>>> applies for
> > > >>>>>>>>>>>    the time_modify attribute.  If the server 
> implementation
> > > >>>> is able to
> > > >>>>>>>>>>>    determine that the file has not been 
> modified since the
> > > >>>> last
> > > >>>>>>>>>>>    time_modify update, the server need not update
> > > >>>> time_modify at
> > > >>>>>>>>>>>    LAYOUTCOMMIT.  At LAYOUTCOMMIT completion, 
> the updated
> > > >>>> attributes
> > > >>>>>>>>>>>    should be visible if that file was 
> modified since the
> > > >>>> latest previous
> > > >>>>>>>>>>>    LAYOUTCOMMIT or LAYOUTGET
> > > >>>>>>>>>>
> > > >>>>>>>>>> I know. However the above paragraph does not 
> state that the
> > > >>>> server
> > > >>>>>>>>>> should make those changes visible to clients 
> other than the
> > > >>>> one that is
> > > >>>>>>>>>> writing.
> > > >>>>>>>>>>
> > > >>>>>>>>>> Section 18.32.4 states that writes will cause the
> > > >>>> time_modified and
> > > >>>>>>>>>> change attributes to be updated (if and only 
> if the file data
> > > >>>> is
> > > >>>>>>>>>> modified). Several other sections rely on this 
> behaviour,
> > > >>>> including
> > > >>>>>>>>>> section 10.3.1, section 11.7.2.2, and section 11.7.7.
> > > >>>>>>>>>>
> > > >>>>>>>>>> The only 'special behaviour' that I see 
> allowed for pNFS is
> > > >>>> in section
> > > >>>>>>>>>> 13.10, which states that clients can't expect 
> to see changes
> > > >>>>>>>>>> immediately, but that they must be able to expect
> > > >>>> close-to-open
> > > >>>>>>>>>> semantics to work. Again, if this is to be the 
> case, then the
> > > >>>> server
> > > >>>>>>>>>> _must_ be able to deal with the case where 
> client 1 dies
> > > >>>> before it can
> > > >>>>>>>>>> issue the LAYOUTCOMMIT.
> > > >>>>>>>>
> > > >>>>>>>> Agreed.
> > > >>>>>>>>
> > > >>>>>>>>>>
> > > >>>>>>>>>>
> > > >>>>>>>>>>>> As I see it, if your server allows one 
> client to read data
> > > >>>> that may have
> > > >>>>>>>>>>>> been modified by another client that holds a 
> WRITE layout
> > > >>>> for that range
> > > >>>>>>>>>>>> then (since that is a visible data change) it should
> > > >>>> provide a change
> > > >>>>>>>>>>>> attribute update irrespective of whether or not a
> > > >>>> LAYOUTCOMMIT has been
> > > >>>>>>>>>>>> sent.
> > > >>>>>>>>>>>
> > > >>>>>>>>>>> the requirement for the server in WRITE's 
> implementation
> > > >>>> section
> > > >>>>>>>>>>> is quite weak: "It is assumed that the act of 
> writing data
> > > >>>> to a file will
> > > >>>>>>>>>>> cause the time_modified and change attributes 
> of the file to
> > > >>>> be updated."
> > > >>>>>>>>>>>
> > > >>>>>>>>>>> The difference here is that for pNFS the 
> written data is not
> > > >>>> guaranteed
> > > >>>>>>>>>>> to be visible until LAYOUTCOMMIT.  In a broader sense,
> > > >>>> assuming the clients
> > > >>>>>>>>>>> are caching dirty data and use a write-behind cache,
> > > >>>> application-written data
> > > >>>>>>>>>>> may be visible to other processes on the same 
> host but not
> > > >>>> to others until
> > > >>>>>>>>>>> fsync() or close() - open-to-close semantics 
> are the only
> > > >>>> thing the client
> > > >>>>>>>>>>> guarantees, right?  Issuing LAYOUTCOMMIT on 
> fsync() and
> > > >>>> close() ensure the
> > > >>>>>>>>>>> data is committed to stable storage and is 
> visible to all
> > > >>>> other clients in
> > > >>>>>>>>>>> the cluster.
> > > >>>>>>>>>>
> > > >>>>>>>>>> See above. I'm not disputing your statement 
> that 'the written
> > > >>>> data is
> > > >>>>>>>>>> not guaranteed to be visible until LAYOUTCOMMIT'. I am
> > > >>>> disputing an
> > > >>>>>>>>>> assumption that 'the written data may be 
> visible without an
> > > >>>> accompanying
> > > >>>>>>>>>> change attribute update'.
> > > >>>>>>>>>
> > > >>>>>>>>>
> > > >>>>>>>>> In other words, I'd expect the following 
> scenario to give the
> > > >>>> same
> > > >>>>>>>>> results in NFSv4.1 w/pNFS as it does in NFSv4:
> > > >>>>>>>>
> > > >>>>>>>> That's a strong requirement that may limit the 
> scalability of
> > > >>>> the server.
> > > >>>>>>>>
> > > >>>>>>>> The spirit of the pNFS operations, at least from Panasas
> > > >>>> perspective was that
> > > >>>>>>>> the data is transient until LAYOUTCOMMIT, 
> meaning it may or may
> > > >>>> not be visible
> > > >>>>>>>> to clients other than the one who wrote it, and 
> its associated
> > > >>>> metadata MUST
> > > >>>>>>>> be updated and describe the new data only on 
> LAYOUTCOMMIT and
> > > >>>> until then it's
> > > >>>>>>>> undefined, i.e. it's up to the server 
> implementation whether to
> > > >>>> update it or not.
> > > >>>>>>>>
> > > >>>>>>>> Without locking, what do the stronger semantics buy you?
> > > >>>>>>>> Even if a client verified the change_attribute 
> new data may
> > > >>>> become visible
> > > >>>>>>>> at any time after the GETATTR if the file/byte 
> range aren't
> > > >>>> locked.
> > > >>>>>>>
> > > >>>>>>> There is no locking needed in the scenario below: 
> it is ordinary
> > > >>>>>>> close-to-open semantics.
> > > >>>>>>>
> > > >>>>>>> The point is that if you remove the one and only 
> way that clients
> > > >>>> have
> > > >>>>>>> to determine whether or not their data caches are 
> valid, then they
> > > >>>> can
> > > >>>>>>> no longer cache data at all, and server 
> scalability will be shot
> > > >>>> to
> > > >>>>>>> smithereens anyway.
> > > >>>>>>>
> > > >>>>>>> Trond
> > > >>>>>>>
> > > >>>>>>>> Benny
> > > >>>>>>>>
> > > >>>>>>>>>
> > > >>>>>>>>> Client 1			Client 2
> > > >>>>>>>>> ========			========
> > > >>>>>>>>>
> > > >>>>>>>>> OPEN foo
> > > >>>>>>>>> READ
> > > >>>>>>>>> CLOSE
> > > >>>>>>>>> 				OPEN
> > > >>>>>>>>> 				LAYOUTGET ...
> > > >>>>>>>>> 				WRITE via DS
> > > >>>>>>>>> 				<dies>...
> > > >>>>>>>>> OPEN foo
> > > >>>>>>>>> verify change_attr
> > > >>>>>>>>> READ if above WRITE is visible
> > > >>>>>>>>> CLOSE
> > > >>>>>>>>>
> > > >>>>>>>>> Trond
> > > >>>>>>>>> _______________________________________________
> > > >>>>>>>>> nfsv4 mailing list
> > > >>>>>>>>> nfsv4@ietf.org
> > > >>>>>>>>> https://www.ietf.org/mailman/listinfo/nfsv4
> > > >>>>>>>
> > > >>>>>>>
> > > >>>>>>> _______________________________________________
> > > >>>>>>> nfsv4 mailing list
> > > >>>>>>> nfsv4@ietf.org
> > > >>>>>>> https://www.ietf.org/mailman/listinfo/nfsv4
> > > >>>>>>>
> > > >>>>>>>
> > > >>>>>
> > > >>>>>
> > > >>>>> _______________________________________________
> > > >>>>> nfsv4 mailing list
> > > >>>>> nfsv4@ietf.org
> > > >>>>> https://www.ietf.org/mailman/listinfo/nfsv4
> > > >>>>>
> > > >>>>> _______________________________________________
> > > >>>>> nfsv4 mailing list
> > > >>>>> nfsv4@ietf.org
> > > >>>>> https://www.ietf.org/mailman/listinfo/nfsv4
> > > >>>>
> > > >>>
> > > >>>
> > > >>
> > > >>
> > > >> --
> > > >> To unsubscribe from this list: send the line 
> "unsubscribe linux-nfs" in
> > > >> the body of a message to majordomo@vger.kernel.org
> > > >> More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> > > >
> > > >
> > > >
> > > > --
> > > > To unsubscribe from this list: send the line 
> "unsubscribe linux-nfs" in
> > > > the body of a message to majordomo@vger.kernel.org
> > > > More majordomo info at  
> http://vger.kernel.org/majordomo-info.html
> > > 
> > 
> > _______________________________________________
> > nfsv4 mailing list
> > nfsv4@ietf.org
> > https://www.ietf.org/mailman/listinfo/nfsv4
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe 
> linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
