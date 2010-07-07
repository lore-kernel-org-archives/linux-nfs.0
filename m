Return-Path: <nfsv4-bounces@ietf.org>
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
In-Reply-To: <1278507985.2804.30.camel@heimdal.trondhjem.org>
References: <A062FCC8662DA848949F7C3046B9BEAE01F3A6ED@us-email.terastack.bluearc.com>
	<A062FCC8662DA848949F7C3046B9BEAE01F3A6EE@us-email.terastack.bluearc.com>
	<6206CE0E-0A32-46A7-B648-3FCC12ED1961@netapp.com>
	<B9A709F368FAAF4DB4B33870F72A141DFB88F3@CORPUSMX30A.corp.emc.com>
	<0E2B1FE3-3B42-4BF2-BECE-A611DADF3983@netapp.com>
	<B9A709F368FAAF4DB4B33870F72A141D01017F94@CORPUSMX30A.corp.emc.com>
	<1278448834.16176.5.camel@heimdal.trondhjem.org>
	<4C346D80.8010405@panasas.com>
	<1278507985.2804.30.camel@heimdal.trondhjem.org>
Date: Wed, 07 Jul 2010 09:18:16 -0400
Message-ID: <1278508696.2804.35.camel@heimdal.trondhjem.org>
Cc: linux-nfs@vger.kernel.org, NFSv4 <nfsv4@ietf.org>, andros@netapp.com
Subject: Re: [nfsv4] 4.1 client - LAYOUTCOMMIT & close
List-Unsubscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=unsubscribe>
List-Archive: <http://www.ietf.org/mail-archive/web/nfsv4>
List-Post: <mailto:nfsv4@ietf.org>
List-Help: <mailto:nfsv4-request@ietf.org?subject=help>
List-Subscribe: <https://www.ietf.org/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@ietf.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@ietf.org
Errors-To: nfsv4-bounces@ietf.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2010-07-07 at 09:06 -0400, Trond Myklebust wrote:
> On Wed, 2010-07-07 at 15:05 +0300, Benny Halevy wrote:
> > On Jul. 06, 2010, 23:40 +0300, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > > On Tue, 2010-07-06 at 15:20 -0400, Daniel.Muntz@emc.com wrote: 
> > >> The COMMIT to the DS, ttbomk, commits data on the DS.  I see it as
> > >> orthogonal to updating the metadata on the MDS (but perhaps I'm wrong).
> > >> As sjoshi@bluearc mentioned, the LAYOUTCOMMIT provides a synchronization
> > >> point, so even if the non-clustered server does not want to update
> > >> metadata on every DS I/O, the LAYOUTCOMMIT could also be a trigger to
> > >> execute whatever synchronization mechanism the implementer wishes to put
> > >> in the control protocol.
> > > 
> > > As far as I'm aware, there are no exceptions in RFC5661 that would allow
> > > pNFS servers to break the rule that any visible change to the data must
> > > be atomically accompanied with a change attribute update.
> > > 
> > 
> > Trond, I'm not sure how this rule you mentioned is specified.
> > 
> > See more in section 12.5.4 and 12.5.4.1. LAYOUTCOMMIT and change/time_modify
> > in particular:
> > 
> >    For some layout protocols, the storage device is able to notify the
> >    metadata server of the occurrence of an I/O; as a result, the change
> >    and time_modify attributes may be updated at the metadata server.
> >    For a metadata server that is capable of monitoring updates to the
> >    change and time_modify attributes, LAYOUTCOMMIT processing is not
> >    required to update the change attribute.  In this case, the metadata
> >    server must ensure that no further update to the data has occurred
> >    since the last update of the attributes; file-based protocols may
> >    have enough information to make this determination or may update the
> >    change attribute upon each file modification.  This also applies for
> >    the time_modify attribute.  If the server implementation is able to
> >    determine that the file has not been modified since the last
> >    time_modify update, the server need not update time_modify at
> >    LAYOUTCOMMIT.  At LAYOUTCOMMIT completion, the updated attributes
> >    should be visible if that file was modified since the latest previous
> >    LAYOUTCOMMIT or LAYOUTGET
> 
> I know. However the above paragraph does not state that the server
> should make those changes visible to clients other than the one that is
> writing.
> 
> Section 18.32.4 states that writes will cause the time_modified and
> change attributes to be updated (if and only if the file data is
> modified). Several other sections rely on this behaviour, including
> section 10.3.1, section 11.7.2.2, and section 11.7.7.
> 
> The only 'special behaviour' that I see allowed for pNFS is in section
> 13.10, which states that clients can't expect to see changes
> immediately, but that they must be able to expect close-to-open
> semantics to work. Again, if this is to be the case, then the server
> _must_ be able to deal with the case where client 1 dies before it can
> issue the LAYOUTCOMMIT.
> 
> 
> > > As I see it, if your server allows one client to read data that may have
> > > been modified by another client that holds a WRITE layout for that range
> > > then (since that is a visible data change) it should provide a change
> > > attribute update irrespective of whether or not a LAYOUTCOMMIT has been
> > > sent.
> > 
> > the requirement for the server in WRITE's implementation section 
> > is quite weak: "It is assumed that the act of writing data to a file will
> > cause the time_modified and change attributes of the file to be updated."
> > 
> > The difference here is that for pNFS the written data is not guaranteed
> > to be visible until LAYOUTCOMMIT.  In a broader sense, assuming the clients
> > are caching dirty data and use a write-behind cache, application-written data
> > may be visible to other processes on the same host but not to others until
> > fsync() or close() - open-to-close semantics are the only thing the client
> > guarantees, right?  Issuing LAYOUTCOMMIT on fsync() and close() ensure the
> > data is committed to stable storage and is visible to all other clients in
> > the cluster.
> 
> See above. I'm not disputing your statement that 'the written data is
> not guaranteed to be visible until LAYOUTCOMMIT'. I am disputing an
> assumption that 'the written data may be visible without an accompanying
> change attribute update'.


In other words, I'd expect the following scenario to give the same
results in NFSv4.1 w/pNFS as it does in NFSv4:

Client 1			Client 2
========			========

OPEN foo
READ
CLOSE
				OPEN
				LAYOUTGET ...
				WRITE via DS
				<dies>...
OPEN foo
verify change_attr
READ if above WRITE is visible
CLOSE

Trond
_______________________________________________
nfsv4 mailing list
nfsv4@ietf.org
https://www.ietf.org/mailman/listinfo/nfsv4
