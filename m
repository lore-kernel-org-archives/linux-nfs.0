From: Bala <balamurugana@yahoo.com>
Subject: RE: NFS mount limitation
Date: Wed, 26 Mar 2003 09:05:06 -0800 (PST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030326170506.68590.qmail@web40610.mail.yahoo.com>
References: <6440EA1A6AA1D5118C6900902745938E07D55437@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from web40610.mail.yahoo.com ([66.218.78.147])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18yEKt-0002xX-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Mar 2003 09:05:11 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <6440EA1A6AA1D5118C6900902745938E07D55437@black.eng.netapp.com>
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

Hi
   Thanks for your detailed FAQ.


Best Regards
Bala

--- "Lever, Charles" <Charles.Lever@netapp.com> wrote:
> hi bala-
> 
> >    Is there any limitation in NFS mount, in particular to NFS 
> > number of mounts?
> >    Is there any way/patch to increase NFS mount counts?
> 
> i'm planning to add a text similar to this to our FAQ list.  let
> me know if this is helpful.  comments from the list are also
> welcome.
> 
> Q. Why can't I mount more than 255 NFS file systems
> on my client?  Why is it sometimes even less than 255?
> 
> A.  On Linux, each mounted file system is assigned a major number,
> which indicates what file system type it is (eg. ext3, nfs, isofs);
> and a minor number, which makes it unique among the file systems
> of the same type.  Linux major and minor numbers have only 8 bits, so
> they may range numerically from zero to 255.  Because a minor number
> has only 8 bits, a system can mount only 255 file systems of the same
> type. So a system can mount up to 255 NFS file systems, another 255 ext3
> file system, 255 more iosfs file systems, and so on.
> 
> For NFS, however, the problem is somewhat worse because it is an
> _anonymous_ file system.  This means that there is no block device
> associated with it, like there is with every local disk-based file
> system.
> /proc, for example, is an anonymous file system; so are other network
> file systems like Intermezzo.  All anonymous file systems share the same
> major number, so there can be a maximum of only 255 anonymous file
> systems mounted on a single host.
> 
> Usually you won't need more than ten or twenty total NFS mounts on
> any given client.  In some large enterprises, though, you might need to
> mount hundreds of NFS file servers.  To work around the limitation on
> the number of NFS file systems you can mount on a single host, you
> should set up and run one of the automounter daemons for Linux.
> An automounter finds and mounts only the file systems that are needed,
> and unmounts any that it finds are inactive.  You can find more
> information on Linux automounters
> <a href="http://linux.kernel.org/pipermail/autofs/">here</a>.


__________________________________________________
Do you Yahoo!?
Yahoo! Platinum - Watch CBS' NCAA March Madness, live on your desktop!
http://platinum.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by:
The Definitive IT and Networking Event. Be There!
NetWorld+Interop Las Vegas 2003 -- Register today!
http://ads.sourceforge.net/cgi-bin/redirect.pl?keyn0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
