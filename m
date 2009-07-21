Return-Path: <nfsv4-bounces@linux-nfs.org>
Date: Tue, 21 Jul 2009 17:47:17 -0400
Message-ID: <fe2cbb740907211447t4dfcc0dara63bb96648599638@mail.gmail.com>
Subject: nfs4 write delegation status
From: "David V. Cloud" <david.v.cloud@gmail.com>
To: nfsv4@linux-nfs.org
Cc: linux-nfs@vger.kernel.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0690846410=="
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============0690846410==
Content-Type: multipart/alternative; boundary=0016367ed4e1c58789046f3e32b1

--0016367ed4e1c58789046f3e32b1
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Hi all,
I was playing with nfs4 delegation, finding out that write delegations have
never been granted. I am using Benny Halevy's git tree with latest
pnfs-block-all branch. With rpcdebug,  I found out that the write-delegation
grant was rejected due to setlease failure with error code (-11, which is
-EAGAIN). I finally figured out that this failure was caused by the
following lines in generic_setlease function,

        if ((arg == F_WRLCK)
            && ((atomic_read(&dentry->d_count) > 1)
            || (atomic_read(&inode->i_count) > 1)))
            goto out;

In my nfsd, the i_count, and d_count turn out to be 2 (no conflicts actaully
exist in my test case), so write-delegations always failed. I did find some
similar posts on nfs4 related mail lists about this problem. One possible
hack by Ajay could be found at
http://osdir.com/ml/linux.nfsv4/2006-08/msg00063.html

I am curious whether there is any progress in awarding write delegation in
current linux nfs4 implementation (for example, any git branch with write
delegation enabled I can pull?) Or, is write-delegation feature available in
other systems like OpenSolaris?

Any suggestion if I would like to enable and test write delegation? I think
some changes are needed to the setlease interface, right?

Thanks,
David

--0016367ed4e1c58789046f3e32b1
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<meta http-equiv=3D"Content-Type" content=3D"text/html; charset=3Diso-8859-=
1">Hi all, <br>I was playing with nfs4 delegation, finding out that write d=
elegations have never been granted. I am using Benny Halevy's git tree with=
 latest pnfs-block-all branch. With rpcdebug,&nbsp; I found out that the wr=
ite-delegation grant was rejected due to setlease failure with error code (=
-11, which is -EAGAIN). I finally figured out that this failure was caused =
by the following lines in generic_setlease function, <br>
<br>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; if ((arg =3D=3D F_WRLCK)<br>&nbsp=
;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &amp;&amp; ((atomic_rea=
d(&amp;dentry-&gt;d_count) &gt; 1)<br>&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;=
 &nbsp;&nbsp;&nbsp; || (atomic_read(&amp;inode-&gt;i_count) &gt; 1)))<br>&n=
bsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp; goto out;<br><br>In =
my nfsd, the i_count, and d_count turn out to be 2 (no conflicts actaully e=
xist in my test case), so write-delegations always failed. I did find some =
similar posts on nfs4 related mail lists about this problem. One possible h=
ack by Ajay could be found at<br>
<a href=3D"http://osdir.com/ml/linux.nfsv4/2006-08/msg00063.html">http://os=
dir.com/ml/linux.nfsv4/2006-08/msg00063.html</a><br><br>I am curious whethe=
r there is any progress in awarding write delegation in current linux nfs4 =
implementation (for example, any git branch with write delegation enabled I=
 can pull?) Or, is write-delegation feature available in other systems like=
 OpenSolaris? <br>
<br>Any suggestion if I would like to enable and test write delegation? I t=
hink some changes are needed to the setlease interface, right?<br><br>Thank=
s,<br>David<br>

--0016367ed4e1c58789046f3e32b1--

--===============0690846410==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0690846410==--
