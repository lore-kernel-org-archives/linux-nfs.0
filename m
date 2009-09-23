From: hongpo gao <gaohhpp@hotmail.com>
Subject: =?windows-1256?Q?a_question?= =?windows-1256?Q?_abount_id?=
	=?windows-1256?Q?mapd=FE?=
Date: Wed, 23 Sep 2009 18:44:08 +0800
Message-ID: <COL101-W29D4B28A8FCF99B81BCAE6A6DB0@phx.gbl>
References: <1252611727-19078-1-git-send-email-jlayton@redhat.com>
	<20090910202825.GL14406@fieldses.org>
	<20090910170024.2853a48e@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1427551447=="
To: <linux-nfs@vger.kernel.org>, <nfsv4@linux-nfs.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20090911153904.GG2095@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


 <20090911153904.GG2095@fieldses.org>
MIME-Version: 1.0

--===============1427551447==
Content-Type: multipart/alternative;
	boundary="_9197ae1b-b1f2-46dd-80ef-7ce76a037f16_"


 <20090911153904.GG2095@fieldses.org>
MIME-Version: 1.0

--_9197ae1b-b1f2-46dd-80ef-7ce76a037f16_
Content-Type: text/plain; charset="windows-1256"
Content-Transfer-Encoding: quoted-printable



hello,=20

I have a question about idmap. Should I send the mail to linux-nfs@vger.k=
ernel.org?
The question is as follows:

In Linux Kernel fs/nfs/idmap.c,=20
The
process will call rpc_queue_upcall in the nfs_idmap_id function, then
it will wait on the waitqueue util the userspace write msg into the
idmap rpc_pipe.=20

In userspace idmapd.c file,
the nfscb will read the rpc_pipe by aiomicio(read, ...), write the rpc_pi=
pe by atomicio(write,...) in the end.
my
question is : if the rpc.idmapd deamon is killed in the duration time
that between atomicio(read,.. ) and atomic(write,...), will the kernel
thread will always sleep on the wait_queue? That is to say, will the
rpc_queue_upcall be never return ?


thanks,=20
Best Regards,
 		 	   		 =20
_________________________________________________________________
Invite your mail contacts to join your friends list with Windows Live Spa=
ces. It's easy!
http://spaces.live.com/spacesapi.aspx?wx_action=3Dcreate&wx_url=3D/friend=
s.aspx&mkt=3Den-us
--_9197ae1b-b1f2-46dd-80ef-7ce76a037f16_
Content-Type: text/html; charset="windows-1256"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style><!--
.hmmessage P
{
margin:0px;
padding:0px
}
body.hmmessage
{
font-size: 10pt;
font-family:Verdana
}
--></style>
</head>
<body class=3D'hmmessage'>
<br>hello, <br><br>I have a question about idmap. Should I send the mail =
to linux-nfs@vger.kernel.org?<br>The question is as follows:<br><br>In Li=
nux Kernel fs/nfs/idmap.c, <br>The
process will call rpc_queue_upcall in the nfs_idmap_id function, then
it will wait on the waitqueue util the userspace write msg into the
idmap rpc_pipe. <br><br>In userspace idmapd.c file,<br>the nfscb will rea=
d the rpc_pipe by aiomicio(read, ...), write the rpc_pipe by atomicio(wri=
te,...) in the end.<br>my
question is : if the rpc.idmapd deamon is killed in the duration time
that between atomicio(read,.. ) and atomic(write,...), will the kernel
thread will always sleep on the wait_queue? That is to say, will the
rpc_queue_upcall be never return ?<br><br><br>thanks, <br>Best Regards,<b=
r> 		 	   		  <br /><hr />Invite your mail contacts to join your friends =
list with Windows Live Spaces. It's easy! <a href=3D'http://spaces.live.c=
om/spacesapi.aspx?wx_action=3Dcreate&wx_url=3D/friends.aspx&mkt=3Den-us' =
target=3D'_new'>Try it!</a></body>
</html>
--_9197ae1b-b1f2-46dd-80ef-7ce76a037f16_--

--===============1427551447==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============1427551447==--
