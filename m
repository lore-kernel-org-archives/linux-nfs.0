Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:50711 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbbFHFT3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jun 2015 01:19:29 -0400
Message-ID: <557525DD.6070300@oracle.com>
Date: Sun, 07 Jun 2015 22:19:25 -0700
From: Shirley Ma <shirley.ma@oracle.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [RFC PATCH V3 0/7] nfsd/sunrpc: prepare nfsd to add workqueue support
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patchset was originally written by Jeff Layton from adding support for a workqueue-based nfsd. I am helping on stability test and performance analysis. There are some workloads benefit from global threading mode, some workloads benefit from workqueue mode. I am still investigating on how to make workqueue mode better to bid global theading mode. I am splitting the patchset into two parts: one is preparing nfsd to add workqueue mode, one is adding workqueue mode. The test results show that the first part doesn't cause much performance change, the results are within the variation from each run.

sunrpc: add a new svc_serv_ops struct and move sv_shutdown into it
sunrpc: move sv_function into sv_ops
sunrpc: move sv_module parm into sv_ops
sunrpc: turn enqueueing a svc_xprt into a svc_serv operation
sunrpc: abstract out svc_set_num_threads to sv_ops
sunrpc: move pool_mode definitions into svc.h
sunrpc: factor svc_rqst allocation and freeing from sv_nrthreads refcounting

 fs/lockd/svc.c                  |   7 ++-
 fs/nfs/callback.c               |   6 ++-
 fs/nfsd/nfssvc.c                |  17 ++++--
 include/linux/sunrpc/svc.h      |  68 +++++++++++++++++-------
 include/linux/sunrpc/svc_xprt.h |   1 +
 net/sunrpc/svc.c                | 113 +++++++++++++++++++---------------------
 net/sunrpc/svc_xprt.c           |  10 ++--
 7 files changed, 135 insertions(+), 87 deletions(-)

Shirley
