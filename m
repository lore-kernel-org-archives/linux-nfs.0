Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:49591
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757932Ab0HCWUJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 18:20:09 -0400
Date: Wed, 4 Aug 2010 00:20:02 +0200
From: Michael Guntsche <mike@it-loops.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Kerberos auth Problem with nfs3/4
Message-ID: <20100803222002.GA1741@marvin.comsick.at>
References: <20100803154556.GA6262@gibson.comsick.at>
 <20100803194342.GE31579@fieldses.org>
 <20100803211906.GA24236@gibson.comsick.at>
 <20100803213650.GJ31579@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100803213650.GJ31579@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010.08.03 17:36:50 , J. Bruce Fields wrote:
> That's actually a client-side complaint--if you're seeing it on the
> server then it's probably the server trying to do a callback to an NFSv4
> client.  Are you running rpc.gssd as well as rpc.svcgssd on the server?
> Might want to if you want delegations to work (but it's not a critical
> problem).

I started rpc.gssd in verbose mode on the server and actually saw this.

rpc.gssd -vvf:
==============

beginning poll
destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt46
handling gssd upcall (/var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt47)
handle_gssd_upcall: 'mech=krb5 uid=0 target=nfs@zaphod.comsick.at service=* enctypes=18,17,16,23,3,1,2 '
handling krb5 upcall (/var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt47)
process_krb5_upcall: service is '*'
Successfully obtained machine credentials for principal 'nfs/gibson.comsick.at@COMSICK.AT' stored in ccache 'FILE:/tmp/krb5cc_machine_COMSICK.AT'
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_COMSICK.AT' are good until 1280909701
using FILE:/tmp/krb5cc_machine_COMSICK.AT as credentials cache for machine creds
using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_COMSICK.AT
creating context using fsuid 0 (save_uid 0)
creating tcp client for server zaphod.comsick.at
DEBUG: port already set to 32844
creating context with server nfs@zaphod.comsick.at
WARNING: Failed to create krb5 context for user with uid 0 for server zaphod.comsick.at
WARNING: Failed to create machine krb5 context with credentials cache FILE:/tmp/krb5cc_machine_COMSICK.AT for server zaphod.comsick.at
WARNING: Machine cache is prematurely expired or corrupted trying to recreate cache for server zaphod.comsick.at
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_COMSICK.AT' are good until 1280909701
INFO: Credentials in CC 'FILE:/tmp/krb5cc_machine_COMSICK.AT' are good until 1280909701
using FILE:/tmp/krb5cc_machine_COMSICK.AT as credentials cache for machine creds
using environment variable to select krb5 ccache FILE:/tmp/krb5cc_machine_COMSICK.AT
creating context using fsuid 0 (save_uid 0)
creating tcp client for server zaphod.comsick.at
DEBUG: port already set to 32844
creating context with server nfs@zaphod.comsick.at
WARNING: Failed to create krb5 context for user with uid 0 for server zaphod.comsick.at
WARNING: Failed to create machine krb5 context with credentials cache FILE:/tmp/krb5cc_machine_COMSICK.AT for server zaphod.comsick.at
WARNING: Failed to create machine krb5 context with any credentials cache for server zaphod.comsick.at
doing error downcall
destroying client /var/lib/nfs/rpc_pipefs/nfsd4_cb/clnt47

gibson being the server and zaphod being the client here. As you said the server tries to connect back to the client which fails since rpc.svcgssd is not running on the client. Should the server try to connect back to the client this way in the first place and if yes shouldn't he stop trying after seeing that it is not working?

Kind regards,
Michael
