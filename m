From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.6.0-test1 ltsp server nfs problem  AND closed lists issues
Date: Fri, 25 Jul 2003 10:37:29 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16160.31689.824153.711205@gargle.gargle.HOWL>
References: <3F1D22BF.1000707@esoft.pf>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19fqbC-0004ro-00
	for <nfs@lists.sourceforge.net>; Thu, 24 Jul 2003 17:38:18 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <jd-girard@esoft.pf>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Fri, 25 Jul 2003 10:37:53 +1000
To: Jean-Denis Girard <jd-girard@esoft.pf>
In-Reply-To: message from Jean-Denis Girard on Tuesday July 22
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

On Tuesday July 22, jd-girard@esoft.pf wrote:
> Hi,
> 
> We are running our office in a LTSP environment.
> 
> I installed 2.6.0-test1 on the server only, and it seems to work fine
> (I'm sending this mail from this server), but my LTSP thin clients can
> no longer mount their root partition. I get:
> 
> ...
> Mounting root filesystem: ... from: ...
> Doing the pivot_root
> nfs: nfs server ... not responding, still trying
> nfs: task 83 can't get a request slot
> 
> And then nothing more...

Jean-Denis sent this to the list because I asked him too.  I like all
questions and answers to go through the list so that information is
spread around and publicly archived.
But he got an 'awaiting moderator approval' and so resent it to me and
we ended up completely resolving the issue before the moderator got
around to forwarding this original to the list :-(

I am really quite unimpressed with the idea of have the list closed to
non-subscribers.   I appreciate that some see spam as a problem and I
am happy for it to be addressed but I DON'T think closing the list is
an appropriate response.


Anyway, the result of the problem was that with 2.6.0-test1, the
server was willing to handle 32K reads, to the client tried 32K reads,
and some bit of the network did not succeed in letting a 32K UDP
packet (about 20 IP fragments) get back to the client completely.
Using a mount option of
    rsize=8192
resolved the problem.

Possibly one for the FAQ...

NeilBrown


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
