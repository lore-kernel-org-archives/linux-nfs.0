Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:27540 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755680Ab3DJRB7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Apr 2013 13:01:59 -0400
Subject: Re: [PATCH] Allow GSSAPI to try to acquire credentials first.
From: Simo Sorce <simo@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        =?ISO-8859-1?Q?G=FCnther?= Deschner <gdeschner@redhat.com>
In-Reply-To: <1365611394.8465.11.camel@leira.trondhjem.org>
References: <1365605450-3009-1-git-send-email-simo@redhat.com>
	 <1365606394.3499.3.camel@leira.trondhjem.org>
	 <1365610175.20560.71.camel@willson.li.ssimo.org>
	 <1365611394.8465.11.camel@leira.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Apr 2013 13:01:56 -0400
Message-ID: <1365613316.20560.82.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-04-10 at 16:29 +0000, Myklebust, Trond wrote:
> On Wed, 2013-04-10 at 12:09 -0400, Simo Sorce wrote:
> > On Wed, 2013-04-10 at 15:06 +0000, Myklebust, Trond wrote:
> > > On Wed, 2013-04-10 at 10:50 -0400, Simo Sorce wrote:
> > > 
> > > > This way all applications that need access to krb5 protected shares do not need
> > > > to be taught how to initiate crdentials on their own, nor they need to be
> > > > wrapped in additional init scripts like k5start or use wasteful cronjobs to
> > > > keep credentials fresh. All is needed is to drop a keytab with the right keys
> > > > in a special location on the system and gss-proxy will do the rest.
> > > 
> > > Can you explain further? Will this for instance work with Active
> > > Directory servers as well as MIT and Heimdal?
> > 
> > GSS-Proxy on the client works only with MIT 1.11 as explained, but the
> > patch itself does not depend on GSS-Proxy so it is safe from rpc.gssd to
> > include it.
> 
> OK.
> 
> > GSS-Proxy doesn't really care what it the Kerberos infrastructure is
> > used on the KDC, so it will work with any KDC, be it MIT, Heimdal or
> > Active Directory.
> 
> So what kind of privileges do the keys in this keytab need in order to
> allow gss-proxy to perform automatic renewal of gss sessions?

Sorry I am not sure I understand the question.

Let me make an example that may answer your question though.

Assume you have a cronjob that runs as the user 'apache' (assume uid
1234) that needs access to a nfs share to write some backup.

All you need to do is obtain a keytab for apache@EXAMPLE.COM and place
it in /var/lib/gssproxy/clients/1234.keytab and gss-proxy will use this
keytab to get a ticket for the principal apache@EXAMPLE.COM when the
user apache walks into the nfs mountpoint and triggers a gss auth
request via rpc.gssd

Note that the principal name do not really need to match the local user
name, all is needed is that the principal in the client keytab is
allowed access by nfs server to the directory the local user is walking
in.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

