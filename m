From: Ben Leslie <benno@sesgroup.net>
Subject: mountd --no-tcp -p bugs?
Date: Tue, 11 Feb 2003 11:28:46 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030211002846.GC7774@retsil.sesgroup.com.au>
Reply-To: benno@sesgroup.net
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from holly.sesgroup.net
	([203.108.123.37] helo=holly.sesgroup.com.au ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18iOIA-0004wV-00
	for <nfs@lists.sourceforge.net>; Mon, 10 Feb 2003 16:28:55 -0800
Received: from retsil.sesgroup.com.au (retsil.sesgroup.com.au [10.0.0.59])
	by holly.sesgroup.com.au (Postfix) with ESMTP id CED643405D
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 11:28:48 +1100 (EST)
To: nfs@lists.sourceforge.net
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

Hi all,

I'm running into a couple of problems with mountd.

I'm using nfs-kernel-server version 1:1.0-2 package 
provided in Debian stable. However looking at the source
seems to indicate the same problems would exist in current
cvs version.

Problem 1/

The -n flag (short for --no-tcp) is ignored.

To reproduce: rpc.mountd -n

The problem seems to be in utils/mountd/mountd.c.

while ((c = getopt_long(argc, argv, "o:Fd:f:p:P:hN:V:v", longopts, NULL)) != EOF)

Probably should be:

while ((c = getopt_long(argc, argv, "o:Fd:f:p:P:hN:V:vn", longopts, NULL)) != EOF)


Problem 2/

The --no-tcp and -p <portnum> options don't play well together. 
Specifically, if you specify --no-tcp the -p option is ignored. I couldn't
find anything to indicate that this was the desired behaviour.

The problem here seems to be in the rpc_init() function (support/nfs/rpcmisc.c).

Specifically this bit:

if ((_rpcfdtype == 0) || (_rpcfdtype == SOCK_DGRAM)) {
	static SVCXPRT *last_transp = NULL;
 
	if (_rpcfdtype == 0) {
		if (last_transp
		    && (!defport || defport == last_transp->xp_port)) {
			transp = last_transp;
			goto udp_transport;
		}
		if (defport == 0)
			sock = RPC_ANYSOCK;
		else if ((sock = makesock(defport, IPPROTO_UDP)) < 0) {
			xlog(L_FATAL, "%s: cannot make a UDP socket\n",
					name);
		}
	}
	if (sock == RPC_ANYSOCK)
		sock = svcudp_socket (prog, 1);
	transp = svcudp_create(sock);


defport is only looked at if the _rpcfgtype is set to zero, which 
seems to me to be incorrect behaviour. However, since the rpc_init()
function is probably used by things other than mountd, chaning this
behaviour may have other unintended side affects. (Or I could be wrong
and this is indeed the correct behaviour, in which case the docs should
probably explain this.)

Cheers,

Benno



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
