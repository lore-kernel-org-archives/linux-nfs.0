Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-ID: <4BB4A9CF.3000809@s3group.cz>
Date: Thu, 01 Apr 2010 16:12:31 +0200
From: Ondrej Valousek <webserv@s3group.cz>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: why does each NFS mount have (at least) 2 rpc_clnt's ?
References: <20100401084620.3475d4c0@barsoom.rdu.redhat.com>	
	<1270127869.3533.12.camel@localhost.localdomain>	
	<4BB49F0D.80009@s3group.cz>
	<1270130860.3533.19.camel@localhost.localdomain>
In-Reply-To: <1270130860.3533.19.camel@localhost.localdomain>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: multipart/mixed; boundary="===============0318646023=="
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

--===============0318646023==
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: 7bit

<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><html><head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
</head>
<body bgcolor="#ffffff" text="#000066">
Ok, I see, thanks. It is possible but it unfortunately also causes my
server to panic <span class="moz-smiley-s1"><span> :-) </span></span><br>
Different story anyway...<br>
O.<br>
<blockquote cite="mid:1270130860.3533.19.camel@localhost.localdomain" type="cite">
  <pre wrap="">Yes. That's exactly what it is supposed to allow (and btw, mounting
filesystems both ro and rw should be possible now).

Cheers
  Trond
  </pre>
</blockquote>
<br>
</body>
</html>

--===============0318646023==
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--===============0318646023==--
