From: <Sun_Peixing@emc.com>
Subject: Build error of latest Linux-pnfs 2.6.31
Date: Fri, 11 Sep 2009 18:29:19 -0400
Message-ID: <44328C067A5E0945856BF1EF5BE23689A29888@CORPUSMX50C.corp.emc.com>
References: <4AA8C597.8080809@panasas.com>	<1252574717-30074-1-git-send-email-bhalevy@panasas.com><1252583366.8722.121.camel@heimdal.trondhjem.org> <4AA8F229.2060404@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>,
	<Sacks_Larry@emc.com>
To: <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mexforward.lss.emc.com ([128.222.32.20]:26758 "EHLO
	mexforward.lss.emc.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753713AbZIKWsY convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Sep 2009 18:48:24 -0400
In-Reply-To: <4AA8F229.2060404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I got the following error from include/linux/stats.h.  It looks
obviously that the line 481 and line 499 are duplicated.   If I remove
line 481 from that file, then I got error in the end  
"ERROR: "nfs4_reset_lease" [fs/nfsd/nfsd.ko] undefined!".   

Could you tell me how to fix that?    I downloaded the package using git
by doing:      

git clone git://git.linux-nfs.org/projects/bhalevy/linux-pnfs.git

On 09/11/2009.  So I got the latest patch.

When Make started,  I got error from 

Thanks for help

Peixing

  CC [M]  fs/nfsd/nfs4proc.o
In file included from fs/nfsd/nfs4proc.c:47:
include/linux/nfsd/state.h:483: warning: struct nfs4_layoutrecall
declared inside parameter list
include/linux/nfsd/state.h:483: warning: its scope is only this
definition or declaration, which is probably not what you want
include/linux/nfsd/state.h:484: warning: struct nfs4_layoutrecall
declared inside parameter list
include/linux/nfsd/state.h:485: warning: struct nfs4_layoutrecall
declared inside parameter list
include/linux/nfsd/state.h:487: warning: struct nfs4_layoutrecall
declared inside parameter list
include/linux/nfsd/state.h:518: error: static declaration of
release_pnfs_ds_dev_list follows non-static declaration
include/linux/nfsd/state.h:481: error: previous declaration of
release_pnfs_ds_dev_list was here
make[2]: *** [fs/nfsd/nfs4proc.o] Error 1
