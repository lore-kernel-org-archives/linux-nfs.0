From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [Patch] Linux NFS & Heartbeat Failover (RH9.0)
Date: Wed, 20 Aug 2003 10:02:59 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16194.47795.334036.788895@gargle.gargle.HOWL>
References: <1061046205.3f3e47bd69679@mail.aidasystems.com>
	<16191.24979.340685.673333@gargle.gargle.HOWL>
	<1061293989.3f420fa55fa3a@mail.aidasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-ha@lists.linux-ha.org, forsberg@cendio.se
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19pGRT-0000E8-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Aug 2003 17:03:11 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <tim@aidasystems.com>) (for <nfs@lists.sourceforge.net>)
	(for <linux-ha@lists.linux-ha.org>) (for <forsberg@cendio.se>) By
	note With Smtp ; Wed, 20 Aug 2003 10:03:00 +1000
To: Tim Hasson <tim@aidasystems.com>
In-Reply-To: message from Tim Hasson on Tuesday August 19
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

On Tuesday August 19, tim@aidasystems.com wrote:
> Hi,
> 
> Neil, Thank you very much for your very useful patch. Unfortunately, I didnt 
> realize this was against ~current (2.6.x ?) therefore it failed horribly :/
> I modified it against 2.4.20-19 (redhat9's kernel-source updated), and it 
> works as expected. The nfsd on port 2049 no longer responds on eth0 when it 
> gets a request on eth0:0, but instead replies on the if/addr it received the 
> connection from.
> Keep up the good work!

That patch was against a 2.4 kernel, but it must have been different
enough from yours that patch failed to apply it ('wiggle' would have
worked).

The code in 2.6 is quite different due to the zero-copy stuff.  Linus
recently accepted the 2.6 equivalent patch so this will definately be
fixed in 2.6.0, and probably in 2.4.23 as well.

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by Dice.com.
Did you know that Dice has over 25,000 tech jobs available today? From
careers in IT to Engineering to Tech Sales, Dice has tech jobs from the
best hiring companies. http://www.dice.com/index.epl?rel_code=104
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
