Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:58879 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753836Ab0DSQKc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Apr 2010 12:10:32 -0400
Date: Mon, 19 Apr 2010 18:10:29 +0200
From: Stefan =?iso-8859-1?Q?Kr=FCger?= <stadtkind2@gmx.de>
To: linux-nfs@vger.kernel.org
Subject: Re: strange performance issues with OS X 10.6 client
Message-ID: <20100419161029.GB3716@gmx.de>
References: <20100415214900.GA4143@web.de>
 <20100419122120.GA3716@gmx.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100419122120.GA3716@gmx.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Ok, how about this one..

FreeBSD nfsstat -s (statistics zeroed before running tar) after extracting
Cocoa-3rd.tgz ->

Server Info:
Getattr   Setattr    Lookup  Readlink      Read     Write    Create Remove
    628      6419      5871         0       627      2488      1989 627
Rename      Link   Symlink     Mkdir     Rmdir   Readdir  RdirPlus Access
     0         0         0       227         0         0         0 5529
    Mknod    Fsstat    Fsinfo  PathConf    Commit
        0         2         1         1      2318
Server Ret-Failed
             5871
Server Faults
            0
Server Cache Stats:
   Inprog      Idem  Non-idem    Misses
        0         0         0         0
Server Write Gathering:
 WriteOps  WriteRPC   Opsaved
     2488      2488         0


Fedora 12 nfsstat -s ->

Server rpc stats:
calls      badcalls   badauth    badclnt    xdrcall
33275      0          0          0          0       

Server nfs v3:
null         getattr      setattr      lookup       access       readlink     
0         0% 627       1% 6426     19% 8523     25% 9111     27% 0         0% 
read         write        create       mkdir        symlink      mknod        
994       2% 2362      7% 1996      5% 221       0% 0         0% 0         0% 
remove       rmdir        rename       link         readdir      readdirplus  
660       1% 0         0% 0         0% 0         0% 0         0% 1         0% 
fsstat       fsinfo       pathconf     commit       
1         0% 0         0% 0         0% 2353      7% 

So... 33275 RPC calls for 1589 directories/files?
