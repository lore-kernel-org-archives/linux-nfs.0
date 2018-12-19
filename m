Return-Path: <SRS0=a7kO=O4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=BIGNUM_EMAILS,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,T_MIXED_ES,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF0C6C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 10:33:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8E1F521873
	for <linux-nfs@archiver.kernel.org>; Wed, 19 Dec 2018 10:33:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="lVSvTOJq"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727317AbeLSKdm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 19 Dec 2018 05:33:42 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:39916 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726812AbeLSKdl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Dec 2018 05:33:41 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBJAOv1F100853;
        Wed, 19 Dec 2018 10:33:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type; s=corp-2018-07-02;
 bh=tnlyvJJaogy9t5GJTXIhGl2VukS+bSo3o4M5FCNOfEw=;
 b=lVSvTOJqYFuSNYQnp3BHZaCnBdJMglMKBHLRK31l6a46iIWHjN1+73vdFvtoySDnkTdb
 UqUwIf772q0E9IKjmyUC/J0bqTi76AvoqonwClpbqpXU0LCmEwZgOobdEHRLwSgXMoRF
 4tq7ur0wZZkPE9IV7NxEizYOpMP5Jzge5NJc+kShbNblCXLGn+kLS8Pxy9V726fKgwaI
 oGMIzUuZlHLM6iaJ/LQ2XsHHYLalmcW3j3riayLg2xWm9NVdYCXSAG5x3G+M91o9g9nM
 tjSldSPz7YSV/clfewgUyo1yIj7WTw9FfN1GOvbdQvItKNnyIpyMrvdevVcHeTr0ZcAP 0Q== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2pct8r0ca7-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 19 Dec 2018 10:33:37 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBJAXang028837
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 19 Dec 2018 10:33:37 GMT
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBJAXaCF022113;
        Wed, 19 Dec 2018 10:33:36 GMT
Received: from kadam (/41.202.241.41)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 19 Dec 2018 02:33:35 -0800
Date:   Wed, 19 Dec 2018 13:33:29 +0300
From:   Dan Carpenter <dan.carpenter@oracle.com>
To:     jlayton@kernel.org, NeilBrown <neilb@suse.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [bug report] nfs: make sillyrename an async operation
Message-ID: <20181219103329.GA28137@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9111 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=524
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812190091
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[ Ancient code.  But NeilB changed get_cred() recently so Smatch thinks
  it understands it now.  - dan ]

Hello Jeff Layton,

The patch d3d4152a5d59: "nfs: make sillyrename an async operation"
from Sep 17, 2010, leads to the following static checker warning:

	fs/nfs/unlink.c:351 nfs_async_rename()
	warn: 'data->cred' isn't an ERR_PTR

fs/nfs/unlink.c
   330  struct rpc_task *
   331  nfs_async_rename(struct inode *old_dir, struct inode *new_dir,
   332                   struct dentry *old_dentry, struct dentry *new_dentry,
   333                   void (*complete)(struct rpc_task *, struct nfs_renamedata *))
   334  {
   335          struct nfs_renamedata *data;
   336          struct rpc_message msg = { };
   337          struct rpc_task_setup task_setup_data = {
   338                  .rpc_message = &msg,
   339                  .callback_ops = &nfs_rename_ops,
   340                  .workqueue = nfsiod_workqueue,
   341                  .rpc_client = NFS_CLIENT(old_dir),
   342                  .flags = RPC_TASK_ASYNC,
   343          };
   344  
   345          data = kzalloc(sizeof(*data), GFP_KERNEL);
   346          if (data == NULL)
   347                  return ERR_PTR(-ENOMEM);
   348          task_setup_data.callback_data = data;
   349  
   350          data->cred = get_current_cred();
   351          if (IS_ERR(data->cred)) {

get_current_cred() always returns a valid pointer, I think?  Can we
just remove this condition?

   352                  struct rpc_task *task = ERR_CAST(data->cred);
   353                  kfree(data);
   354                  return task;
   355          }

regards,
dan carpenter
