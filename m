From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] nfs-utils - Silencing mountd
Date: Fri, 18 Jun 2004 08:13:48 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040617221347.GC31781@sgi.com>
References: <40D063D1.9010208@RedHat.com> <20040616224504.GB29503@sgi.com> <40D1EA4A.6080002@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb58w-0002wC-Nf
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 15:13:58 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Bb58w-0006xO-BV
	for nfs@lists.sourceforge.net; Thu, 17 Jun 2004 15:13:58 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <40D1EA4A.6080002@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, Jun 17, 2004 at 03:00:26PM -0400, Steve Dickson wrote:
> Greg Banks wrote:
> 
> >Actually, I find the "authenticated mount request from..."  message
> >useful [...]
> >
> True... the authenticated message is a good way to see that
> a client is able to communicate with the server... but
> in reality it doesn't mean much... and every error message
> in the same code path (i.e. in  auth_authenticate()) gives a pretty
> detail error message of who and what happen..

Sure, but I'm talking about cases where you get wacky interop
problems in NFS or NLM traffic in the few minutes after the mount
sequence.

Also, there are times when it's useful to "tail -f" the syslog
looking for these messages, e.g. at Cthon you can tell whose
testing against your server at any moment.  If you see a strange
message you can wander over and talk to those guys and start a
debugging session.  This was how the MacOS X lock cookie issue
was found at Cthon '03.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
