From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Wildcards matching ".": exports bug or just documentation bug?
Date: Fri, 4 Oct 2002 12:57:04 +0100
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <20021004125704.A8969@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Tweedie <sct@redhat.com>, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

Hi,

mountd treats wildcards in hostnames in the exports file as matching
anything, including ".".

However, the exports man page explicitly states that "*" and "?" do not
match ".":

    Machine names may contain the wildcard characters * and ?.  This can
    be used to make the exports file more compact; for instance,
    *.cs.foo.edu matches all hosts in the domain cs.foo.edu. However,
    these wildcard characters do not match the dots in a domain name, so
    the above pattern does not include hosts such as a.b.cs.foo.edu.

So, which is right, the actual behaviour or the documented behaviour?
I'd tend to lean towards the former.

--Stephen
