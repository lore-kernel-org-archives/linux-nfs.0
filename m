From: Suresh Chadive <n8d11007@ccs.iitb.ac.in>
Subject: Re: problem with exports file
Date: Wed, 21 Aug 2002 03:46:50 +0530 (IST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.GHP.4.43.0208210332050.21317-100000@hp10.ccs.iitb.ernet.in>
References: <20020820134521.352272bd.ian@ihtruelsen.2y.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailhost.iitb.ac.in ([203.197.74.142])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hHFl-0000gP-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 15:13:33 -0700
To: NFS List <nfs@lists.sourceforge.net>
In-Reply-To: <20020820134521.352272bd.ian@ihtruelsen.2y.net>
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


I just guess a possible solution for it.

" If a directory is exported, its parent and child
  directories can not be exported if they are in the same file
  system "
[ www.tldp.org, NFS-Howto ]

If this is true and your case will become an example
of it, then minion is given both a child directory and
its parent.

First, in the wild card usage
	/(child directory)   *.ihtruelsen.2y.net

Second, in the laststatement
	/ minion.ihtruelsen.2y.net

So, the solution may be excluding minion from
the wildcard group. It may be done in two
ways :

1) Is there any way to exclude a particular machine from wild
card ? - I do not know it and like to hear from the group.
If exists, exclude it.

2) If the number of machines is less, write all
avoiding wildcards. Wildcards, I think, are not
preferable for some other reasons also.

regards,
-suresh

----------------------
SURESH CHADIVE

H9, #319,
Indian Instt. of Technology,
Bombay.

e-mail :  csuresh@iitbombay.org


On Aug 21, 2002, at 12:23am, Ian Truelsen wrote:

> Date: Wed, 21 Aug 2002 00:23:01 +0530
> From: Ian Truelsen <ian@ihtruelsen.2y.net>
> To: NFS List <nfs@lists.sourceforge.net>
> Subject: [NFS] problem with exports file
>
> I am not sure what it is that I am doing wrong here, but it is driving
> me nuts.
>
> Here is what I am trying to set up: I want some individual directories
> on the server to be available to my whole lan, but I want one machine to
> have access to the whole directory tree for administration. Here is what
> I have in my exports file:
>
> /home/ian *.ihtruelsen.2y.net(rw,no_root_squash)
> /media *.ihtruelsen.2y.net(rw,no_root_squash)
> /home/httpd *.ihtruelsen.2y.net(rw,no_root_squash)
> / minion.ihtruelsen.2y.net(rw,no_root_squash)
>
> This works fine for the individual directories, but the whole structure
> will not mount on the minion machine, giving me a Permission denied
> error.
>
> Can anyone give me some idea why this won't work as imagined?
>
> --
> Ian Truelsen
> Masters program in Philosophy
> University of Manitoba, Winnipeg, Canada
> BA (Wilfrid Laurier University)
> Email: ian@ihtruelsen.2y.net
> Homepage: http://www.ihtruelsen.2y.net
> PGP key available at: http://www.ihtruelsen.2y.net/pgp.html
> and http://pgp.mit.edu (search 'ihtruelsen')





-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
