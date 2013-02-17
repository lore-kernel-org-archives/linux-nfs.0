Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754809Ab3BQBsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Feb 2013 20:48:07 -0500
Message-ID: <512036AC.4010404@RedHat.com>
Date: Sat, 16 Feb 2013 20:47:24 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: Re: [PATCH 10/15] NFS: Client implementation of Labeled-NFS
References: <1360327163-20360-1-git-send-email-SteveD@redhat.com> <1360327163-20360-11-git-send-email-SteveD@redhat.com> <20130212230346.GN10267@fieldses.org> <511FED8E.7020308@RedHat.com> <20130216223035.GB28824@fieldses.org> <51203168.7050204@RedHat.com>
In-Reply-To: <51203168.7050204@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 16/02/13 20:24, Steve Dickson wrote:
>> > You may want to just remove nfs4_label_init() entirely.  This is the
>> > only caller, and it doesn't seem very useful.
> Its a useful way to reset len back to NFS4_MAXLABELLEN as well as 
> lfs and pi back to zero... 
On second thought... It is useless... I'll remove it... 

steved.
