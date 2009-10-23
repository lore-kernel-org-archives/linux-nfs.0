From: Ben DJ <bendj095124367913213465@gmail.com>
Subject: are multiple FSIDs supported?
Date: Fri, 23 Oct 2009 11:32:44 -0700
Message-ID: <babafd2f0910231132n464da0crc2a5cc0427af9a40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:57530 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753011AbZJWSc7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Oct 2009 14:32:59 -0400
Received: by pzk1 with SMTP id 1so2924pzk.33
        for <linux-nfs@vger.kernel.org>; Fri, 23 Oct 2009 11:33:04 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm building an NFSv4 FileServer.  My goal is to service multiple
machines on a LAN, each with their own, isolated namespace (I'm not
sure that's the right terminology).

Reading the man page it seems that only ONE fsid=0 export is allowed
per server.  And that subdirectories of that root CAN be exported, but
always under the same/one root.

That doesn't seem like "good isolation" to me.

My goal would be to export, for example

 /nfs1 & it's subdirs ONLY to LAN box1
 /nfs2 & it's subdirs ONLY to LAN box2
 etc

I've seen some mentions & discussion online of multiple-fsid's, where
/nfs1 would be exported as a root under fsid=0, /nfs2 under fsid=1,
etc.

But this approach doesn't look like its currently supported or
recommended.  Even if it was I haven't found anything that says how a
nfsv4 client would ADDRESS the specific fsid's.  Something in the
mount's URI I guess.

I know I might still be stuck in NFSv3 thinking about this, and NFSv4
subdirs might be isolated "well enough".

BenDJ
