Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:41703 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570Ab3JLRxd convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 12 Oct 2013 13:53:33 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.6 \(1510\))
Subject: Re: nfs RPC: AUTH_GSS upcall timed out and running nfs v4 without full kerberos : how?
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <52598677.1000708@hanaden.com>
Date: Sat, 12 Oct 2013 13:53:17 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <438A0982-93FB-45A2-86D7-035C37378A57@oracle.com>
References: <52598677.1000708@hanaden.com>
To: hanasaki <hanasaki@hanaden.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Oct 12, 2013, at 1:27 PM, hanasaki <hanasaki@hanaden.com> wrote:

> 1. Below appears to require krb for auth.  Is this correct?  How can nfs v4 be setup and used over tcp? udp? and not require a full kerberos server setup?

Simply ensure that rpc.gssd is running on your NFS clients.  The exact procedure varies among Linux distributions.  There is no need to perform any other configuration.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




