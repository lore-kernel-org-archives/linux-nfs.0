Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:27260 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932481Ab3GWQGi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Jul 2013 12:06:38 -0400
Date: Tue, 23 Jul 2013 19:06:27 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: re: NFSv4: Fix a regression against the FreeBSD server
Message-ID: <20130723160627.GA2370@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Trond Myklebust,

This is a semi-automatic email about new static checker warnings.

The patch b4a2cf76ab7c: "NFSv4: Fix a regression against the FreeBSD 
server" from Jul 17, 2013, leads to the following Smatch complaint:

fs/nfs/nfs4xdr.c:1103 encode_attrs()
	 error: we previously assumed 'label' could be null (see line 1059)

fs/nfs/nfs4xdr.c
  1058		}
  1059		if (label) {
                    ^^^^^
New check.

  1060			len += 4 + 4 + 4 + (XDR_QUADLEN(label->len) << 2);
  1061			bmval[2] |= FATTR4_WORD2_SECURITY_LABEL;
  1062		}
  1063	
  1064		if (bmval[2] != 0)
  1065			bmval_len = 3;
  1066		else if (bmval[1] != 0)
  1067			bmval_len = 2;
  1068		else
  1069			bmval_len = 1;
  1070	

[snip]

  1094		if (bmval[1] & FATTR4_WORD1_TIME_MODIFY_SET) {
  1095			if (iap->ia_valid & ATTR_MTIME_SET) {
  1096				*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
  1097				p = xdr_encode_hyper(p, (s64)iap->ia_mtime.tv_sec);
  1098				*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
  1099			} else
  1100				*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
  1101		}
  1102		if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
  1103			*p++ = cpu_to_be32(label->lfs);
                                           ^^^^^^^^^^
Old dereference.

  1104			*p++ = cpu_to_be32(label->pi);
  1105			*p++ = cpu_to_be32(label->len);

regards,
dan carpenter
