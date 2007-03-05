From: "Matt Proud" <matt.proud.list@gmail.com>
Subject: Possible causes for rpc.mountd consuming 100 percent CPU.
Date: Sun, 4 Mar 2007 19:47:52 -0600
Message-ID: <a6a251db0703041747l6e539890v7496b616aa8d5cc8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HO2Ip-0000OB-Mi
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 17:47:51 -0800
Received: from wr-out-0506.google.com ([64.233.184.224])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HO2Ir-0001wT-Hq
	for nfs@lists.sourceforge.net; Sun, 04 Mar 2007 17:47:53 -0800
Received: by wr-out-0506.google.com with SMTP id i30so1230954wra
	for <nfs@lists.sourceforge.net>; Sun, 04 Mar 2007 17:47:52 -0800 (PST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello,

I am curious why rpc.mountd would be consuming 100 percent CPU on a
mail server. I have noticed this periodically, and it does not appear
to matter how overloaded the server is with respect to mail clients.

I have started rpc.mountd with debugging enabled, and so far nothing
interesting appears in the logs. NFS functions perfectly on the
client-side.

Here's a brief description of the setup:

Mail resides on the mail server locally, and it is exported to
clients. The chief way for clients to access the mail is via IMAP, but
we do export the mail for the convenience of our power-users who care
to manually grep through mail data. Mail is stored in the maildir
format. Given this context, the amount of manual access that occurs
over NFS for this mail is miniscule, so I am surprised to see this
happening.

The mail server is running Ubuntu 6.06 with kernel 2.6.15-28-amd64-k8.
NFS is version 1.0.7-3ubuntu2. The mail data is stored on a RAID1
array on a tuned ext3 filesystem. We are considering switching to
RAID10 in the near future, even though we have not experienced many
I/O bottlenecks.

When rpc.mountd acts funny, an attached strace reveals the a select
function call occurring very rapidly:

select(1024, [3 4 5 6 7 32 33 34 35 36 37 38 39 40], NULL, NULL, NULL)
= 9 (in [32 33 34 35 36 37 38 39 40])

When rpc.mountd behaves normally a periodic select statement with
fewer file descriptors is called periodically.

We currently have the following options set:

options lockd nlm_udpport=32768 nlm_tcpport=32768

/var/maildir    localhost(rw,sync,no_root_squash) \
                        @mail_clients(rw,sync) @nfs_server(rw,sync) \
                        xxxx(rw,sync) xxxxxxxx(rw,sync) \
                        xxxxxx(rw,sync,no_root_squash) xxxx.xxx.xxx.xxx(ro,sync)

Our clients have the following set:

maildir -fstype=nfs,_netdev,tcp,timeo=600,retrans=2,rsize=32768,wsize=32768,hard,intr,nosuid,nodev,noacl,rw
    mail:/var/maildir

If the kernel server is restarted, rpc.mountd behaves normally for a time.

The server is multi-core, so the consumption is not a major problem;
but the fact that it is occurring is troubling.

Best,

Matt

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
