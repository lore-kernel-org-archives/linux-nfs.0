From: Bill Johnstone <beejstone3@yahoo.com>
Subject: Re: Performance tuning on modern 2.6 series kernels
Date: Thu, 14 Jun 2007 21:17:23 -0700 (PDT)
Message-ID: <473059.4636.qm@web63901.mail.re1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hz3FX-00005V-IE
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 21:17:27 -0700
Received: from web63901.mail.re1.yahoo.com ([69.147.97.116])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Hz3FZ-0005Wl-C0
	for nfs@lists.sourceforge.net; Thu, 14 Jun 2007 21:17:30 -0700
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

--- Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Wed, 2007-06-13 at 10:45 -0700, Bill Johnstone wrote:

> > 4. tcp_window_scaling, tcp_timestamps, and tcp_sack .  There is an
> > IBM
> > Linux NFS performance tuning article at
> > http://www.ibm.com/developerworks/eserver/library/es-033104.html
> > which
> > mentions turning off all three of these features, and presumaby the
> > tcp_window_scaling causes them to see an effective MSS less than
> > what
> > they get without it.  Is there merit to turning these features off
> > today, on modern 2.6 kernels?
> 
> Those were in a section on "Web applications", not NFS AFAICS.
> Their
> main reason for turning off window scaling is presumably to work
> around
> the "broken router" issue??? (see http://lwn.net/Articles/92727/)
> Otherwise, given their choices of tcp_rmem/tcp_wmem/tcp_mem, the
> decision to turn off window scaling seems very odd...
 
Yes, I was mistaken about the overall intent of the article, it was
on generic "performance optimization" but came up as a relevant hit in
a
Google search for NFS Linux performance tuning.
 
They are not very clear about the specific reasons for turning each
specific feature off, but they indicate that having them on reduced
their MSS below the maximum (and expected) value for 1500 byte MTU
ethernet.  Perhaps, as you say, this is an implementation artifact of
the tcp window scaling "broken router" workaround.  Either way, it
seems like in a modern implementation, we should leave these features
on.




 
____________________________________________________________________________________
Don't get soaked.  Take a quick peak at the forecast
with the Yahoo! Search weather shortcut.
http://tools.search.yahoo.com/shortcuts/#loc_weather

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
