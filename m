From: hgichon <hgichon@gmail.com>
Subject: Sometimes df is not updated after remove within xfs via nfs.
Date: Thu, 30 Apr 2009 18:44:56 +0900
Message-ID: <49F97318.4040103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=EUC-KR
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: xfs@oss.sgi.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi guys.

I used xfs and nfs for a long time.
Recently, I have problem with df when removing files via nfs client.
df result is not updated both local and nfs client.
It's hard to reproducing same problem.
But I have seen the problem several times in this month.

I can't remember exactly, df was updated when new files was created.

Are there any known issue or any check point?
Any comments appreciated.

Related xfs/nfsd Kernel Version.
- 2.6.23.1
- 2.6.24.7
- 2.6.27.21

My Environment
- nfs client (AIX5.3 , CentOS 5.3)
- nfs tcp v3
- Intel DR2500, Xeon Dual core, 4G RAM

- kpkim
