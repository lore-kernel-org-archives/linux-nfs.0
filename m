Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from edge10.ethz.ch ([82.130.75.186]:20496 "EHLO edge10.ethz.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751090AbdEELLS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 May 2017 07:11:18 -0400
To: <linux-nfs@vger.kernel.org>
From: Stefan Walter <stefan.walter@inf.ethz.ch>
Subject: Issue with mixed short and fully qualified names with NFS4+KRB5 and
 libnfsidmap
Message-ID: <c6de9e41-b7d1-ab24-cce3-ce6201423072@inf.ethz.ch>
Date: Fri, 5 May 2017 13:05:07 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a proposal to improve libnfsidmap to support kerberized NFS4 
server and client environments with a mixed setup using short and fully 
qualified names.

My situation is the following: I want to use a file server that is set 
up to use fully qualified names (sssd.conf: use_fully_qualified_names = 
true). I have no say in the configuration of said server. On the clients 
I want to use short names since there is only one realm anyway and the 
lengthy johndoe@example.com user and group names are too cumbersome.

On all Linux distros I have tried this works with the exception of the 
chgrp (and chown) command. Changing the group always results in an 
'Operation not permitted' error.

I have tracked down the source of the problem to nsswitch.so in 
libnfsidmap. In nss.c the write_name() function creates the user@domain
string that is sent over the wire. For short names it should actually 
send user@realm@domain, at least if the server is configured to use 
fully qualified names. I have patched the function to do this and 
verified that this actually fixes my problem with chgrp.

Has this been noticed or discussed before? Would a patch be welcome and 
have a chance to be integrated in the upstream libnfsidmap that would 
then trickle down to the various distros?

Stefan




