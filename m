From: "Weber, Eugene F (Gene)" <efw@agere.com>
Subject: RE: RPC Time Out
Date: Fri, 5 Dec 2003 07:06:29 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <FEF7905AD5F3DE4988CBEF096C280A4C1A490C@pauex2ku02.agere.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1ASEjB-0002Zl-5o
	for nfs@lists.sourceforge.net; Fri, 05 Dec 2003 04:06:33 -0800
Received: from alageremail2.agere.com ([192.19.192.110])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1ASEjA-00048k-NH
	for nfs@lists.sourceforge.net; Fri, 05 Dec 2003 04:06:32 -0800
To: "Ian Kent" <raven@themaw.net>
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

Hi Ian,

Thanks for the suggestion. showmount -e on the server produced:
Export list for localhost.localdomain:

So I ran exportfs -ra. That produced:
exportfs: No 'sync' or 'async' option specified for export
"192.168.2.51"/dev/cdrom".
  Assuming default behavior ('sync').
  NOTE: this default has changed from previous versions
exportfs: No 'sync' or 'async' option specified for export
"192.168.2.51"/home/efw".
  Assuming default behavior ('sync').
  NOTE: this default has changed from previous versions
192.168.2.51:/dev/hdc: Not a directory

Now showmount -e on the server produced:
Export list for localhost.localdomain:
/dev/hdc 192.186.2.51
/home/efw 192.186.2.51

(Why /dev/hdc and not /dev/cdrom?)

But the next time I ran it I got an RPC timeout. Same with running
showmount -e 192.186.2.57 on the client. One time it shows the two =
lines,
other times it times out.

Every time I try mount 192.168.2.57:/home/efw /fred I get and RPC =
timeout.

Could my network be slow or dropping data?

Thanks & Regards,

Gene

-----Original Message-----
From: Ian Kent [mailto:raven@themaw.net]
Sent: Thursday, December 04, 2003 1:16 AM
To: Weber, Eugene F (Gene)
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] RPC Time Out


On Thu, 4 Dec 2003, Ian Kent wrote:

> On Mon, 1 Dec 2003, Weber, Eugene F (Gene) wrote:
>
> >
> > SETTING UP THE CLIENT
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> > rpcinfo -p on the Debian laptop gave an rpc error. I saw
> > that none of the services existed anywhere on the
> > machine. I installed package "portmap_5-2_i386.deb"
> > and package "nfs-common_1.0-2_i386.deb". After the
> > successful installs, portmap, statd and lockd all existed
> > under /sbin. The installation also said it started each of
> > the services. rpcinfo -p now showed:
> >
> > program vers proto port
> > 100000 2 tcp 111 portmapper
> > 100000 2 udp 111 portmapper
> > 100024 1 udp 1024 status
> > 100024 1 tcp 1024 status
> >
> > I though perhaps lockd was not started, but executing it
> > and then checking rpcinfo -p gives the same result??
> > The shown services now seemed to be launched at boot
> > up.
> >
> > rpcinfo -p 192.168.2.57 from the client gives the same
> > result as doing rpcinfo -p on the server. Likewise doing
> > rpcinfo -p 192.168.2.51 from the server gives the same
> > result as doing rpcinfo -p on the client.
>
> But what does a showmount -e show on the server and what does
> a showmount -e 192.168.2.57 give on the client.
>
>

All I'm trying to say is "can you see the servers' export list".

ie. showmount -e <server ip>

on the client

You can check your exports list on the server using exportfs but if you
use showmount -e it will fail if the rpc service is not registered.

Just a check.

If your export lists are not what you expect then re-export them with

exportfs -ra

should fix it up.

Worth a try!

--=20

   ,-._|\    Ian Kent
  /      \   Perth, Western Australia
  *_.--._/   E-mail: raven@themaw.net
        v    Web: http://themaw.net/


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
