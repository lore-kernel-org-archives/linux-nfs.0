Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.gnuher.de ([78.47.12.54]:49168 "EHLO mail.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429Ab2BIJLT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Feb 2012 04:11:19 -0500
Received: from ultimate100.geggus.net ([2a01:198:297:1::1])
	by mail.gnuher.de (envelope-from
	<news@geggus.net>)
	with esmtpsa (TLS1.0:RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	id 1RvPis-0007MZ-9n
	for linux-nfs@vger.kernel.org; Thu, 09 Feb 2012 09:51:22 +0100
Received: from news  by ultimate100.geggus.net (envelope-from
	<news@geggus.net>)
	with local (Exim 4.72)
	id 1RvPiq-0001wO-69
	for linux-nfs@vger.kernel.org; Thu, 09 Feb 2012 09:51:20 +0100
To: linux-nfs@vger.kernel.org
From: Sven Geggus <lists@fuchsschwanzdomain.de>
Subject: Re: NFS4: ID-mapping Problem with Linux Client and NetApp Server
Date: Thu, 9 Feb 2012 08:51:20 +0000 (UTC)
Message-ID: <jh01e8$6oh$1@ultimate100.geggus.net>
References: <20120208144923.GA16606@geggus.net> <4F3295CC.7020503@netapp.com> <20120208161212.GA18284@geggus.net> <4F32B9BB.8030504@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bryan Schumaker <bjschuma@netapp.com> wrote:

> Any of the v4 compounds should work.  How about "78.524457   10.1.7.174 -> 10.1.1.14    NFS V4 COMPOUND Call <EMPTY> PUTFH;LOOKUP;GETFH;GETATTR"?

OK, here is this one:

I skipped IP and TCP headers, starting with RPC:

Internet Protocol, Src: 10.1.7.174 (10.1.7.174), Dst: 10.1.1.14 (10.1.1.14)
Transmission Control Protocol, Src Port: 793 (793), Dst Port: nfs (2049), Seq: 1629, Ack: 1657, Len: 196
Remote Procedure Call, Type:Call XID:0x1496ad4c
    Fragment header: Last fragment, 192 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0000 1100 0000 = Fragment Length: 192
    XID: 0x1496ad4c (345419084)
    Message Type: Call (0)
    RPC Version: 2
    Program: NFS (100003)
    Program Version: 4
    Procedure: COMPOUND (1)
    Credentials
        Flavor: RPCSEC_GSS (6)
        Length: 32
        GSS Version: 1
        GSS Procedure: RPCSEC_GSS_DATA (0)
        GSS Sequence Number: 10
        GSS Service: rpcsec_gss_svc_none (1)
        GSS Context: <DATA>
            length: 12
            contents: <DATA>
    Verifier
        Flavor: RPCSEC_GSS (6)
        GSS Token: 00000025602306092A864886F71201020201011100FFFFFF...
            GSS Token Length: 37
            GSS-API Generic Security Service Application Program Interface
                OID: 1.2.840.113554.1.2.2 (KRB5 - Kerberos 5)
                krb5_blob: 01011100FFFFFFFFA4C9778A70A0DFF48E0AC0599AD935BE
                    krb5_tok_id: KRB5_GSS_GetMIC (0x0101)
                    krb5_sgn_alg: HMAC (0x0011)
                    krb5_snd_seq: A4C9778A70A0DFF4
                    krb5_sgn_cksum: 8E0AC0599AD935BE
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    minorversion: 0
    Operations (count: 4)
        Opcode: PUTFH (22)
            filehandle
                length: 28
                [hash (CRC-32): 0x285d5ed2]
                decode type as: unknown
                filehandle:
                2A04000001000000050000000000042A0100000002000000...
        Opcode: LOOKUP (15)
            Filename: vol
                length: 3
                contents: vol
                fill bytes: opaque data
        Opcode: GETFH (10)
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

Answer:
Internet Protocol, Src: 10.1.1.14 (10.1.1.14), Dst: 10.1.7.174 (10.1.7.174)
Transmission Control Protocol, Src Port: nfs (2049), Dst Port: 793 (793), Seq: 1657, Ack: 1825, Len: 300
Remote Procedure Call, Type:Reply XID:0x1496ad4c
    Fragment header: Last fragment, 296 bytes
        1... .... .... .... .... .... .... .... = Last Fragment: Yes
        .000 0000 0000 0000 0000 0001 0010 1000 = Fragment Length: 296
    XID: 0x1496ad4c (345419084)
    Message Type: Reply (1)
    [Program: NFS (100003)]
    [Program Version: 4]
    [Procedure: COMPOUND (1)]
    Reply State: accepted (0)
    [This is a reply to a request in frame 40]
    [Time from request: 0.000489000 seconds]
    Verifier
        Flavor: RPCSEC_GSS (6)
        GSS Token: 00000025602306092A864886F71201020201011100FFFFFF...
            GSS Token Length: 37
            GSS-API Generic Security Service Application Program Interface
                OID: 1.2.840.113554.1.2.2 (KRB5 - Kerberos 5)
                krb5_blob: 01011100FFFFFFFF4E710FD04090348728ADC573608BB721
                    krb5_tok_id: KRB5_GSS_GetMIC (0x0101)
                    krb5_sgn_alg: HMAC (0x0011)
                    krb5_snd_seq: 4E710FD040903487
                    krb5_sgn_cksum: 28ADC573608BB721
    Accept State: RPC executed successfully (0)
Network File System
    [Program Version: 4]
    [V4 Procedure: COMPOUND (1)]
    Status: NFS4_OK (0)
    Tag: <EMPTY>
        length: 0
        contents: <EMPTY>
    Operations (count: 4)
        Opcode: PUTFH (22)
            Status: NFS4_OK (0)
        Opcode: LOOKUP (15)
            Status: NFS4_OK (0)
        Opcode: GETFH (10)
            Status: NFS4_OK (0)
            Filehandle
                length: 28
                [hash (CRC-32): 0x4cc21d2f]
                decode type as: unknown
                filehandle:
                2B04000001000000050000000000042B0100000002000000...
        Opcode: GETATTR (9)
            Status: NFS4_OK (0)
            GETATTR4res
                resok4
                    obj_attributes
                        attrmask
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
                        attr_vals
                            mand_attr: FATTR4_TYPE (1)
                                nfs_ftype4: NF4DIR (2)
                            mand_attr: FATTR4_CHANGE (3)
                                changeid: 1426762506587602944
                            mand_attr: FATTR4_SIZE (4)
                                size: 0
                            mand_attr: FATTR4_FSID (8)
                                fattr4_fsid
                                    fsid4.major: 2
                                    fsid4.minor: 0
                            recc_attr: FATTR4_FILEID (20)
                                fileid: 1067
                            recc_attr: FATTR4_MODE (33)
                                fattr4_mode: 00
                                    000. .... .... .... = Unknown
                                    .... 0... .... .... = not SUID
                                    .... .0.. .... .... = not SGID
                                    .... ..0. .... .... = not save swapped text
                                    .... ...0 .... .... = no Read permission for owner
                                    .... .... 0... .... = no Write permission for owner
                                    .... .... .0.. .... = no Execute permission for owner
                                    .... .... ..0. .... = no Read permission for group
                                    .... .... ...0 .... = no Write permission for group
                                    .... .... .... 0... = no Execute permission for group
                                    .... .... .... .0.. = no Read permission for others
                                    .... .... .... ...0 = no Execute permission for others
                            recc_attr: FATTR4_NUMLINKS (35)
                                numlinks: 1
                            recc_attr: FATTR4_OWNER (36)
                                fattr4_owner: root@<fqdn>
                                    length: 19
                                    contents: root@<fqdn>
                                    fill bytes: opaque data
                            recc_attr: FATTR4_OWNER_GROUP (37)
                                fattr4_owner_group: nobody
                                    length: 6
                                    contents: nobody
                                    fill bytes: opaque data
                            recc_attr: FATTR4_RAWDEV (41)
                                specdata1: 0
                                specdata2: 0
                            recc_attr: FATTR4_SPACE_USED (45)
                                space_used: 0
                            recc_attr: FATTR4_TIME_ACCESS (47)
                                seconds: 1328776131
                                nseconds: 359437000
                            recc_attr: FATTR4_TIME_METADATA (52)
                                seconds: 1328776131
                                nseconds: 0
                            recc_attr: FATTR4_TIME_MODIFY (53)
                                seconds: 1328776131
                                nseconds: 0

Sven

-- 
"A strategy for rewarding artists that regulates 'copies' makes as much sense
in the digital age as a strategy for controlling greenhouse gases that
regulates breathing." (Lawrence Lessig)
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
