From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: getcwd() returns wrong pathname
Date: Tue, 3 Dec 2002 14:34:47 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15852.9815.372469.298167@notabene.cse.unsw.edu.au>
References: <20021203114545W.miyoshi@hpc.bs1.fc.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18J3qJ-0002pR-00
	for <nfs@lists.sourceforge.net>; Mon, 02 Dec 2002 19:35:27 -0800
Received: From
	notabene.cse.unsw.edu.au ([129.94.233.169] == wireless-169.wireless.cse.unsw.EDU.AU)
	(for <miyoshi@hpc.bs1.fc.nec.co.jp>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Tue, 3 Dec 2002 14:34:48 +1100
To: miyoshi@hpc.bs1.fc.nec.co.jp
In-Reply-To: message from miyoshi@hpc.bs1.fc.nec.co.jp on Tuesday December 3
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

On Tuesday December 3, miyoshi@hpc.bs1.fc.nec.co.jp wrote:
> 
> Hello,
> 
> I'm having problems with linux NFS. Here is my situation.
> 
> When mounting remote linux NFS filesystem to /mnt/xxx/yyy,
> pwd or getcwd() sometimes returns imcomplete pathname.
> We are using linux kernel 2.4.17.
> 
> % mount linuxserver:/mnt/xxx /mnt/xxx
> % cd /mnt/xxx/yyy
> % pwd
> /xxx/yyy       <--- should be /mnt/xxx/yyy
> 
> Is there any ideas or fixes?
> I'll be very gratefull to any suggestion.

Are both client and server Linux?

What does '/bin/pwd' say?

What does
    ls -l /proc/self/cwd
say?

NeilBrown


-------------------------------------------------------
This SF.net email is sponsored by: Get the new Palm Tungsten T 
handheld. Power & Color in a compact size! 
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0002en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
