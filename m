Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:19309 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932992Ab3DJQ34 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 12:29:56 -0400
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Steve Dickson <steved@redhat.com>,
        =?iso-8859-1?Q?G=FCnther_Deschner?= <gdeschner@redhat.com>
Subject: Re: [PATCH] Allow GSSAPI to try to acquire credentials first.
Date: Wed, 10 Apr 2013 16:29:45 +0000
Message-ID: <1365611394.8465.11.camel@leira.trondhjem.org>
References: <1365605450-3009-1-git-send-email-simo@redhat.com>
	 <1365606394.3499.3.camel@leira.trondhjem.org>
	 <1365610175.20560.71.camel@willson.li.ssimo.org>
In-Reply-To: <1365610175.20560.71.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-04-10 at 12:09 -0400, Simo Sorce wrote:
> On Wed, 2013-04-10 at 15:06 +0000, Myklebust, Trond wrote:
> > On Wed, 2013-04-10 at 10:50 -0400, Simo Sorce wrote:
> > 
> > > This way all applications that need access to krb5 protected shares do not need
> > > to be taught how to initiate crdentials on their own, nor they need to be
> > > wrapped in additional init scripts like k5start or use wasteful cronjobs to
> > > keep credentials fresh. All is needed is to drop a keytab with the right keys
> > > in a special location on the system and gss-proxy will do the rest.
> > 
> > Can you explain further? Will this for instance work with Active
> > Directory servers as well as MIT and Heimdal?
> 
> GSS-Proxy on the client works only with MIT 1.11 as explained, but the
> patch itself does not depend on GSS-Proxy so it is safe from rpc.gssd to
> include it.

OK.

> GSS-Proxy doesn't really care what it the Kerberos infrastructure is
> used on the KDC, so it will work with any KDC, be it MIT, Heimdal or
> Active Directory.

So what kind of privileges do the keys in this keytab need in order to
allow gss-proxy to perform automatic renewal of gss sessions?

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
