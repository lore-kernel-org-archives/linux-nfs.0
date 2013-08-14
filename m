Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:46828 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932869Ab3HNTZM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 15:25:12 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1V9ggw-0000JO-Lo
	for linux-nfs@vger.kernel.org; Wed, 14 Aug 2013 21:25:10 +0200
Received: from NORTHWEST-R.edge3.Denver1.Level3.net ([4.28.99.98])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 21:25:10 +0200
Received: from orion by NORTHWEST-R.edge3.Denver1.Level3.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 21:25:10 +0200
To: linux-nfs@vger.kernel.org
From: Orion Poplawski <orion@cora.nwra.com>
Subject: Re: rpc.idmapd: =?utf-8?b?bnNzX2dldHB3bmFtOg==?= name '#' does not map into domain
Date: Wed, 14 Aug 2013 19:24:54 +0000 (UTC)
Message-ID: <loom.20130814T212246-502@post.gmane.org>
References: <loom.20130814T210744-290@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Orion Poplawski <orion@...> writes:

> 
> On our EL6 nfs servers we see periodic messages like:
> 
> Aug 14 12:55:19 alexandria rpc.idmapd[19237]: nss_getpwnam: name '612' does
> not map into domain 'cora.nwra.com'
> 
> I imagine that this is caused by a client actually passing the uid instead
> of the username for some reason but I have no idea how to track down which.
>  Any ideas?

These *appear* to be triggered by the following types of requests:


Network File System, Ops(3): PUTFH SETATTR GETATTR
    [Program Version: 4]
    [V4 Procedure: COMP (1)]
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    minorversion: 0
    Operations (count: 3)
        Opcode: PUTFH (22)
            filehandle
                length: 28
                [hash (CRC-32): 0xcdbd24f8]
                decode type as: unknown
                filehandle: 010006018355CA85FB1E02DF00000000000000000A00682B...
        Opcode: SETATTR (34)
            stateid
                seqid: 0x00000000
                Data: 000000000000000000000000
            obj_attributes
                attrmask
                    recc_attr: FATTR4_OWNER (36)
                        fattr4_owner: 612
                            length: 3
                            contents: 612
                            fill bytes: opaque data
                    recc_attr: FATTR4_OWNER_GROUP (37)
                        fattr4_owner_group: 1001
                            length: 4
                            contents: 1001
            attr_vals: <DATA>
                length: 16
                contents: <DATA>
        Opcode: GETATTR (9)
            GETATTR4args
                attr_request
                    bitmap[0] = 0x0010011a
                        [5 attributes requested]
                        mand_attr: FATTR4_TYPE (1)
                        mand_attr: FATTR4_CHANGE (3)
                        mand_attr: FATTR4_SIZE (4)
                        mand_attr: FATTR4_FSID (8)
                        recc_attr: FATTR4_FILEID (20)
                    bitmap[1] = 0x0030a23a
                        [9 attributes requested]
                        recc_attr: FATTR4_MODE (33)
                        recc_attr: FATTR4_NUMLINKS (35)
                        recc_attr: FATTR4_OWNER (36)
                        recc_attr: FATTR4_OWNER_GROUP (37)
                        recc_attr: FATTR4_RAWDEV (41)
                        recc_attr: FATTR4_SPACE_USED (45)
                        recc_attr: FATTR4_TIME_ACCESS (47)
                        recc_attr: FATTR4_TIME_METADATA (52)
                        recc_attr: FATTR4_TIME_MODIFY (53)


