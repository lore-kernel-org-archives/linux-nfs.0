Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756379Ab3GZPlL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 11:41:11 -0400
Date: Fri, 26 Jul 2013 11:41:10 -0400
To: Spelic <spelic@shiftmail.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Nfs4 idmapping: new kernel sends numeric
Message-ID: <20130726154110.GD30651@fieldses.org>
References: <51F1B0FF.4010602@shiftmail.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <51F1B0FF.4010602@shiftmail.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 26, 2013 at 01:13:03AM +0200, Spelic wrote:
> Hi all
> we have an ubuntu 10.04 NFS4 client and an ubuntu 13.04 NFS4 server. LDAP.
> The serverside filesystem sees perfect UID/GIDs for files, but sends
> numeric ones to client side. Client side then maps to
> nobody/nogroup. Or this is what it seems

The client *should* be able to map those id's.  I think this might be a
bug in older idmapd?

You can work around this by turning off the new server behavior by
setting the nfsd.nfs4_disable_idmapping module parameter to 0.

--b.

> 
> This is a packet from server to client due to an "ls -l"
> 
> 0000  00 25 64 fc 69 c6 52 54  00 15 36 aa 08 00 45 00   .%d.i.RT ..6...E.
> 0010  00 f4 68 22 40 00 40 06  42 39 c0 a8 07 30 c0 a8   ..h"@.@. B9...0..
> 0020  07 28 08 01 03 58 8c 62  27 4e 16 ac d1 51 80 18   .(...X.b 'N...Q..
> 0030  00 bd 90 8f 00 00 01 01  08 0a 1c c8 49 28 05 6c   ........ ....I(.l
> 0040  11 d3 80 00 00 bc 62 a6  2a c7 00 00 00 01 00 00   ......b. *.......
> 0050  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00   ........ ........
> 0060  00 00 00 00 00 00 00 00  00 02 00 00 00 16 00 00   ........ ........
> 0070  00 00 00 00 00 09 00 00  00 00 00 00 00 02 00 10   ........ ........
> 0080  01 1a 00 30 a2 3a 00 00  00 78 00 00 00 01 51 ee   ...0.:.. .x....Q.
> 0090  5a 4f 27 aa 8d 2b 00 00  00 00 49 3e 00 00 45 91   ZO'..+.. ..I>..E.
> 00a0  00 63 f4 8c 43 f5 b7 45  af ac 40 80 06 ce 00 00   .c..C..E ..@.....
> 00b0  00 00 01 c0 00 02 00 00  01 a4 00 00 00 01 00 00   ........ ........
> 00c0  00 04 31 30 33 37 00 00  00 02 32 30 00 00 00 00   ..1037.. ..20....
> 00d0  00 00 00 00 00 00 00 00  00 00 49 3e 10 00 00 00   ........ ..I>....
> 00e0  00 00 51 ee 5a 3d 11 04  0b e0 00 00 00 00 51 ee   ..Q.Z=.. ......Q.
> 00f0  5a 4f 27 aa 8d 2b 00 00  00 00 51 ee 5a 4f 27 aa   ZO'..+.. ..Q.ZO'.
> 0100  8d 2b .+
> 
> 
> The 1037 and 20 you see are the numeric uid and gid being sent to
> client side for one file, but I suspect client side wants usernames
> and groupnames as strings, not as numbers. So remaps to nobody.
> 
> Curiously when clientside creates a file I don't see numeric uid or
> string usernames passing at all, but the filesystem at serverside
> has correct uid/gid for the file being created so somehow they are
> passed. I don't really know how to read the NFS4 packets...
> 
> Is it an /etc/request-key.conf  problem? I just installed keyutils
> but doesn't appear to help.
> 
> This is idmapd.conf on both sides
> ============================
> [General]
> 
> Verbosity = 10
> Pipefs-Directory = /run/rpc_pipefs
> # set your own domain here, if id differs from FQDN minus hostname
> Domain = localdomain
> 
> [Mapping]
> 
> Nobody-User = nobody
> Nobody-Group = nogroup
> 
> [Translation]
> 
> Method = nsswitch
> ============================
> 
> Thanks for any help
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
