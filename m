From: "Iyer, Rahul" <Rahul.Iyer@netapp.com>
Subject: Re: [RFC,PATCH 3/14] knfsd: prepare reply per transport
Date: Thu, 17 May 2007 02:16:46 -0700
Message-ID: <7619F3097FAB384287CF636FF92D0CA10976B38B@exsvl01.hq.netapp.com>
References: <20070516192047.GI9626@sgi.com><C270E33B.3042D%tom@opengridcomputing.com>
	<20070517075342.GG27247@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Peter Leckie <pleckie@melbourne.sgi.com>
To: "Greg Banks" <gnb@sgi.com>,
	"Tom Tucker" <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hoc6O-0003Dx-GY
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 02:16:52 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hoc6Q-0000rg-Ln
	for nfs@lists.sourceforge.net; Thu, 17 May 2007 02:16:54 -0700
In-Reply-To: <20070517075342.GG27247@sgi.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi Greg,
I like the idea of a transport switch for the server side. The way I see
it, it's not just the server, it's also the "callback server" on the
client that can benefit. 

I had a question. Maybe it's a dumb question, and I may be way off base,
but I don't see why we need 2 transport switches - one for the client,
one for the server? Why not have one? 
I've written some code to do NFSv4.1 callbacks and wound up implementing
another "transport". Since in v4.1 it's actually possible for clients to
send requests (fore-channel) and receive callbacks (back channel) over
the same connection, I had to "make" another transport that essentially
did TCP, but used server side conventions for the rpc_xprt_ops send
routines so that the server could use the existing rpc_call_(a)sync()
mechanisms. Similarly, on the client side, I had to implement the
equivalent of the svc_send() routines using the client side xs_tcp_*
routines. The resultant code is reasonably clean, but screams out
"inefficiency" because of the small amount of code sharing that was
actually possible.

Given this, a unified transport switch would really rock. Both the
client and the server treat the connection as a "full duplex" (I mean
can send calls and receive replies on the same connection). One set of
tcp/udp read/write methods for both the client and server. No more
svc_send for the server and xs_*_send_request on the client. The one
true networking way to rule them both! Everything would be much cleaner,
and since we're going down this path, I assumed it's a feasibility study
worth doing. Maybe I'm oversimplifying, but this seems doable. After
all, what we're doing in both cases (client and server) is shoving bits
down a socket. Is my question justified or am I *way* off base and
ignorant of some fundamental issues(s)?
Thanks
Regards
Rahul


> -----Original Message-----
> From: Greg Banks [mailto:gnb@sgi.com] 
> Sent: Thursday, May 17, 2007 12:54 AM
> To: Tom Tucker
> Cc: Linux NFS Mailing List; Talpey, Thomas; Peter Leckie; Greg Banks
> Subject: Re: [NFS] [RFC,PATCH 3/14] knfsd: prepare reply per transport
> 
> On Wed, May 16, 2007 at 04:35:07PM -0500, Tom Tucker wrote:
> > 
> > Greg:
> > 
> > I like this patch organization. I'll replicate this in the 
> integrated 
> > tree...
> 
> Great.
> 
> > > + /* Will be turned off only in gss privacy case: */
> > > + rqstp->rq_sendfile_ok = 1;
> > 
> > I think this belongs in the svc_process logic. It doesn't have 
> > anything to do with the buffer, but rather whether or not 
> GSS is turned on.
> 
> Fixed.
> 
> I'll push a revised patchset including feedback from yourself 
> and Bruce, to you only, in a few minutes.
> 
> Greg.
> --
> Greg Banks, R&D Software Engineer, SGI Australian Software Group.
> Apparently, I'm Bedevere.  Which MPHG character are you?
> I don't speak for SGI.
> 
> --------------------------------------------------------------
> -----------
> This SF.net email is sponsored by DB2 Express Download DB2 
> Express C - the FREE version of DB2 express and take control 
> of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net 
> https://lists.sourceforge.net/lists/listinfo/nfs
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
