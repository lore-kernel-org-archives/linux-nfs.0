Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:21821 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753880Ab2CHKFZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Mar 2012 05:05:25 -0500
Date: Thu, 8 Mar 2012 13:05:17 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: re: NFSv4.1 handle DS stateid errors
Message-ID: <20120308100517.GA31881@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Andy Adamson,

This is a semi-automatic email about new static checker warnings.

The patch 9cb8196839ab: "NFSv4.1 handle DS stateid errors" from Mar 
7, 2012, leads to the following Smatch complaint:

fs/nfs/nfs4filelayout.c:102 filelayout_async_handle_error()
	 warn: variable dereferenced before check 'state' (see line 90)

fs/nfs/nfs4filelayout.c
    89	{
    90		struct nfs_server *mds_server = NFS_SERVER(state->inode);
                                                           ^^^^^^^^^^^^
new dereference.

    91		struct nfs_client *mds_client = mds_server->nfs_client;
    92	
    93		if (task->tk_status >= 0)
    94			return 0;
    95		*reset = 0;
    96	
    97		switch (task->tk_status) {
    98		/* MDS state errors */
    99		case -NFS4ERR_DELEG_REVOKED:
   100		case -NFS4ERR_ADMIN_REVOKED:
   101		case -NFS4ERR_BAD_STATEID:
   102			if (state != NULL)
                            ^^^^^^^^^^^^^

new check.

   103				nfs_remove_bad_delegation(state->inode);
   104		case -NFS4ERR_OPENMODE:

regards,
dan carpenter

