From: Donavan Pantke <avatar@dcr.net>
Subject: Re: RPC timeout errors
Date: Mon, 11 Nov 2002 00:40:03 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200211110040.03963.avatar@dcr.net>
References: <02111100215404.06294@192.168.0.254>
Reply-To: avatar@dcr.net
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ns1.dcr.net ([216.7.64.2] helo=andrew.dcr.net)
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18B7If-0007pw-00
	for <nfs@lists.sourceforge.net>; Sun, 10 Nov 2002 21:39:53 -0800
To: Kevin <Fear@shmack.us>, nfs@lists.sourceforge.net
In-Reply-To: <02111100215404.06294@192.168.0.254>
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

On Monday 11 November 2002 00:21, Kevin wrote:
> I am running an nfs server and client; bot machines having RedHat 7.1
> installed with kernel 2.4.2-2 and nfs-utils-0.3.1-5.  The server seems
> fine. Everything in my host files are perfect.  Infact, i checked my
> messages file in /var and it shows the server allowing an incoming nfs
> connection from client  192.168.0.1.
>
> I have the following line in my /etc/fstab:
> 192.168.0.254:/home/Fear                /mnt/server1          nfs
> rw,hard,intr    0 0
>
> With that added, i used to be able to type mount -a and it would mount
> everything in /etc/fstab.  It tries to mount the nfs, but chokes up & g=
ives
> me the error "mount: RPC: Timed out".  I followed every instruction loc=
ated
> in the Linux NFS HOWTO and it referred me to this e-mail for questions.
>
> Thanks for your time.
>

=09I've run into this before, and the problem is that the mount daemon is=
 trying=20
to reverse and forward resolve that IP address. If you dumped the client =
and=20
server either in a DNS server or in the /etc/hosts file you should see an=
=20
instanteanous mount.

=09To everyone else: Is there a way of turing this off in the mount daemo=
n? I=20
would like to have my auto-install scripts get to NFS without having to a=
dd=20
DNS entries first.

=09Hope this helps!
=09Donavan Pantke


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
