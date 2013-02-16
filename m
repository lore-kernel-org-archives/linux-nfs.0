Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754228Ab3BPU3T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 15:29:19 -0500
Message-ID: <511FEC09.5040809@RedHat.com>
Date: Sat, 16 Feb 2013 15:28:57 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 09/15] NFS: Add label lifecycle management
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com> <1360327163-20360-10-git-send-email-SteveD@redhat.com> <20130212222659.GK10267@fieldses.org>
In-Reply-To: <20130212222659.GK10267@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 12/02/13 17:27, J. Bruce Fields wrote:
>> @@ -2922,6 +2969,7 @@ static int _nfs4_proc_remove(struct inode *dir, struct qstr *name)
>> >  	status = nfs4_call_sync(server->client, server, &msg, &args.seq_args, &res.seq_res, 1);
>> >  	if (status == 0)
>> >  		update_changeattr(dir, &res.cinfo);
>> > +
>> >  	return status;
>> >  }
>> >  
>> > @@ -2965,6 +3013,7 @@ static int nfs4_proc_unlink_done(struct rpc_task *task, struct inode *dir)
>> >  	if (nfs4_async_handle_error(task, res->server, NULL) == -EAGAIN)
>> >  		return 0;
>> >  	update_changeattr(dir, &res->cinfo);
>> > +
>> >  	return 1;
>> >  }
>> >  
> How'd these two hunks end up in here?
I have no idea.. but they are gone..

steved.
