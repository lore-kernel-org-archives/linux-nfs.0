From: "Robert Williamson" <robbiew@us.ibm.com>
Subject: Re: The rpc.mountd program in 1.0.4:
Date: Thu, 17 Jul 2003 11:48:49 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFA6A74120.77FD9CC1-ON85256D66.005BDC4D-86256D66.005C822E@pok.ibm.com>
References: <20030717011422.GA16081@lucon.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from e3.ny.us.ibm.com ([32.97.182.103])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19dBxz-0005Uz-00
	for <nfs@lists.sourceforge.net>; Thu, 17 Jul 2003 09:50:52 -0700
In-Reply-To: <20030717011422.GA16081@lucon.org>
To: "H. J. Lu" <hjl@lucon.org>
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


Neil has a fix for this one:


            On Monday July 14, robbiew@us.ibm.com wrote:
            >
            > The mountd daemon segmentation faults after receiving a m=
ount
            request from
            > the client.  Checking /var/log/messages, I get some stran=
ge
            logs:
            >
            > Jul 14 16:17:25 vega rpc.mountd: authenticated mount requ=
est
            from
            > \200a^U@\200a^U@H=E9^F^HH=E9^F^H\220a^U@\220a^U@\230a^U@\=
230a^U@
            a^U@
            a^U@,=E8^F^H,=E8^F^H=B0a^U@=B0a^U@,a^U@,a^U@Aa^U@Aa^U@Ea^U@=
Ea^U@Da^U@Da^U@Oa^U@Oa^U@=E0a^U@=E0a^U@=E8a^U@=E8a^U@oa^U@oa^U@oa^U@oa^=
U@:793
            >  for /nfsserver/reiserfs (/nfsserver/reiserfs)
            > Jul 14 16:17:25 vega rpc.mountd: MNT1(/nfsserver/ext2) ca=
lled
            >
            >
            > I attached an strace of the rpc.mountd pid during an
            unsuccessful mount
            > request.  I can re-test this on 2.6.0-test1 if needed.

            Thanks.
            There is a stray 'free(hp)' at line 169 in utils/mountd/aut=
h.c,
            in the middle of auth_authenticate.
            Could you remove that and try again?

            NeilBrown



Robert V. Williamson <robbiew@us.ibm.com>
Linux Test Project
IBM Linux Technology Center
Web: http://ltp.sourceforge.net
IRC: #ltp on freenode.irc.net
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
"Only two things are infinite, the universe and human stupidity, and I'=
m
not sure about the former." -Albert Einstein


                                                                       =
                                                                =20
                      "H. J. Lu"                                       =
                                                                =20
                      <hjl@lucon.org>             To:       nfs@lists.s=
ourceforge.net                                                  =20
                      Sent by:                    cc:                  =
                                                                =20
                      nfs-admin@lists.sour        Subject:  [NFS] The r=
pc.mountd program in 1.0.4:                                     =20
                      ceforge.net                                      =
                                                                =20
                                                                       =
                                                                =20
                                                                       =
                                                                =20
                      07/16/2003 08:14 PM                              =
                                                                =20
                                                                       =
                                                                =20




----- Forwarded message from Chris Rankin <cj.rankin@ntlworld.com> ----=
-

Delivered-To: hjl@localhost.lucon.org
From: Chris Rankin <cj.rankin@ntlworld.com>

Jul 15 22:05:50 wellhouse rpc.mountd: authenticated mount request from
(null):759 for /home (/home)

Notice that (null) where it should give the name of the remote client?
And the server crashed when I issued a umount request, too.

My setup is: gcc-3.2.3, glibc-2.3.2, libwrap.a, Linux 2.4.21.

CFLAGS=3D'-O2 -fomit-frame-pointer'
./configure --prefix=3D/usr
            --enable-secure-statd
            --enable-nfsv3
            --enable-rquotad
            --with-statduser=3Dnobody

Cheers,
Chris

----- End forwarded message -----


-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.=

WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the=

same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


=




-------------------------------------------------------
This SF.net email is sponsored by: VM Ware
With VMware you can run multiple operating systems on a single machine.
WITHOUT REBOOTING! Mix Linux / Windows / Novell virtual machines at the
same time. Free trial click here: http://www.vmware.com/wl/offer/345/0
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
