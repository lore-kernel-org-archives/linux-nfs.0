From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: PATCH - SUNRPC 1 of 3 - The new "sk_flags" word in struct svc_sock must be long....
Date: Wed, 21 Aug 2002 09:32:13 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15714.53629.683877.430516@notabene.cse.unsw.edu.au>
References: <15713.50328.541517.124690@notabene.cse.unsw.edu.au>
	<20020820185357.O21269@redhat.com>
	<shsy9b1yvcz.fsf@charged.uio.no>
	<20020820192158.P21269@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hIUB-0006bv-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 16:32:31 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.85] == wireless-085.wireless.cse.unsw.EDU.AU)
	(for <bcrl@redhat.com>) (for <trond.myklebust@fys.uio.no>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Wed, 21 Aug 2002 09:32:16 +1000
To: Benjamin LaHaise <bcrl@redhat.com>
In-Reply-To: message from Benjamin LaHaise on Tuesday August 20
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

On Tuesday August 20, bcrl@redhat.com wrote:
> On Wed, Aug 21, 2002 at 01:16:12AM +0200, Trond Myklebust wrote:
> >      > On Tue, Aug 20, 2002 at 02:24:56PM +1000, Neil Brown wrote:
> >     >> @@ -22,7 +22,7 @@ struct svc_sock {
> >     >>
> >     >> struct svc_serv * sk_server; /* service for this socket */
> >     >> unsigned char sk_inuse; /* use count */
> >     >> - unsigned int sk_flags;
> >     >> + unsigned long sk_flags;
> > 
> >      > Cool, 7 bytes of useless padding on 64 bit architectures.
> > 
> > All down to the sad inability of certain 64-bit "processor architects"
> > to provide for atomic bit operations on 32-bit integers.
> > If the relatively minor bloat in knfsd worries you, then I advise you
> > to take a deep breath before peeking at struct page... 8-)
> 
> You've missed the point.  Between sk_inuse and sk_flags is 7 bytes of 
> padding.  Yes, I'm aware that sk_flags has 7 bytes of unused space, but 
> that's the unavoidable part.  Personally, I think the sunrpc code should 
> do this particular operation differently.

Code is welcome.  Even detailed description of "differently" is
welcome.

At the time, I was interested in "cleaner" and "works", both of which
I achieved.  "best" takes a bit longer.

NeilBrown


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
