Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753023Ab0DNTcx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 15:32:53 -0400
Message-ID: <4BC61839.6000200@RedHat.com>
Date: Wed, 14 Apr 2010 15:32:09 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 10/22] gss_krb5: Add upcall info indicating supported
 	kerberos enctypes
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-5-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-6-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-7-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-8-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-9-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-10-git-send-email-Trond.Myklebust@netapp.com>	 <1271266618-26016-11-git-send-email-Trond.Myklebust@netapp.com>	 <y2t4d569c331004141130z7525d001gcdb81db5b1ede42e@mail.gmail.com>	 <1271270279.22566.22.camel@localhost.localdomain> <y2q4d569c331004141151n9042470aqe3f51e804b3abea9@mail.gmail.com>
In-Reply-To: <y2q4d569c331004141151n9042470aqe3f51e804b3abea9@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 04/14/2010 02:51 PM, Kevin Coffman wrote:
> 
> Hi Steve,
> This surprises me.  I believe this would result in DES being used
> rather than the stronger enctypes.  Can you give me more details of
> the problems you saw?

In limit_krb5_enctypes(), if I did not give gss_set_allowable_enctypes()
the list of enctypes in an increasing order, creating the krb5 context for  
root would fail. When gave them in order root got its context... 

I figured it was some type of krb5 lib quirk, since the default enctypes 
are also in increasing order... 

steved.
 
