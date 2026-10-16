Received: from mail-oo1-f52.google.com (mail-oo1-f52.google.com [209.85.161.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8113345EF32
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 18:00:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792173654; cv=none; b=OsP2knkye32zHDicnxIgYCiV5addebKG+g2tMqRHEtHAx+wrIModYEuHeo1duxaORtz0weT72KNqiSdmkGtJo3dPv1MKyThHEiyEqMBEmRwrN23+OmhY0EN5mfQc/PuWUm3Zr90PKBMpZOMLuBhXZCGRwUGxXAGJfakkOe4svc0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792173654; c=relaxed/simple;
	bh=nPb2xAOTPA5Jzj7V3849vFhyI7LYG23UpHCNgIzxNnE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ArWSfRZCk6jk8b/STSxKpsROKdpVL+rx7OSAjpWSak7I2v4IXwQGd6ijW8kwjOJvaMYaLd6N+ohlbPOGSFlRBh/MU9cN8otiFF8LnIWfz/rTMFkPlzwcOUktOoca8xlTfAqcJM0jX0tDthGN1jWfSAPRKZ4pe7HG4mj23wMy8io=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=fh/pjK1o; arc=none smtp.client-ip=209.85.161.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fh/pjK1o"
Received: by mail-oo1-f52.google.com with SMTP id 006d021491bc7-6dd7070699eso141210eaf.3
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:00:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792173651; x=1792778451; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=LH0AfvhKok7pWrRSzpsoD05yiVZMlAUV31g8aUX6KWk=;
        b=fh/pjK1oUBUOHsJzEWWZkSVNnS2owe7FopnhAoYvpk1N1JafW0ABkEC+x7xrOCpbSx
         +sIqIbR4c47tFMBnGRsSwiNoTg61I3OK06xs7Bx73AT9JYVN/KlYBTT5D1N4F/E/akNZ
         gvyACEAYgNmnPbTAli5L5/GVKbgcpH8YodOL4ZF3wvknXsSjz6vpfMBsKhWPzn36QdyY
         eo3krAl3l2ufd0guuIHHwUItJwAisXsMp4CJNhw2ab51b8Wma618Vi2e/7+0fBtLvj8Z
         6Bvk4Xfdkd9/QRAsiEPMGatTNCuY5//nHAlhraax100Hqbu2z9CkXF3Cz0JxxlsMbYht
         o2/g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792173651; x=1792778451;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=LH0AfvhKok7pWrRSzpsoD05yiVZMlAUV31g8aUX6KWk=;
        b=TaKZT/K1B7F6V4I0+hKadYDYz2GiU7z/OCrVRrlJW/1FZ0Q/FVph2dgE+uq+KkQpUs
         F4y7kYJJvXJSTQbfgNCgAV0NJoYkYfWX9aFIa662k02XQNstlTtlFq9c87C/H8xiCctJ
         1EhyoMp/kVdgynU6gf4ZFc/pwU9jTCZWCsiSEAgQrAYQfOkG00LDnld7Nd7Ow+RlNRyp
         jBs+s8dvT8moGQYL1rQz0ByfeLJHzOfn/1G5V8oykno6H7WAGSVf9khwhfMqeM7f3GPh
         nwYC9H793Xi/GOz68fx3ZHKP4Kam2BYGARYktte8ay7FbMl4c2S3BxkxaRPsNZc07BzR
         4gAQ==
X-Forwarded-Encrypted: i=1; AKwUvByviDezpwb7KN++DMHwKV/qHZyEAtshDDDmr6L4T4+fZjNJDohBZ3MHgyDbLhD72UCDAflEXExTaLc=@vger.kernel.org
X-Gm-Message-State: AFq9FYIFPndxczKGyJAVXBx9SxQAT3vJM6Wm16gV07mvbc3haeNwFW8u
	9jG1gWbPsWPY1asuzmtQYZgsNtFriZMWZ8xYQOSc0IkVYALkllc/tOP7YmIvYBWTKjry/BYs2Ke
	O8Vc0
X-Gm-Gg: AYBFou0HNxQBmpyYItW6GpcE++HMF64d6mIFosJz4d0wHPhz/ZTSLPHRgIB8rD3+6iV
	fPM9rCpch1OPHI2WU7WGdL1eUAtsxKid1Fd7IgeTl+DgPXmD7QSrfogzcZ3bwPAND5GqQvsEPpL
	u2XzmcQuS+O/o4DONh1qwpTnaFkK4aQSpkv5HN9KpYPhWoY6eAdGssu8YVTFDVS/BQsMyJmoHg0
	HpgICEF30T4+3esglxyV1LPAtgNpqH/xurJVFzXxuJDf1BAwH/38X3VPh+tCXTZvsrrunJX+sBt
	O52P3RXpO9kZMyX5ydB4376G3Chujrrh9zXhQi02UCyOW8soeUFVZGx2679YeIthyT5+R4Cb2j7
	SriC0bv6yxzgm61YT+nK5iWcwLAcZ6A/yUmttHujmiegg2nwNUTa+K/sCgRUL1e/M0KalgaezRr
	13rPyjL5xRTGxiIQQk+a3MsoWduagJHdoh/PYVPTgJc4xgneqz9k50zWoqLLWI+wxvqm/670zTb
	Iq6BvEgrkZ+rg6Dkw==
X-Received: by 2002:a05:6820:208d:b0:702:96cf:69ae with SMTP id 006d021491bc7-70357f996a6mr128280eaf.73.1792173651018;
        Fri, 16 Oct 2026 11:00:51 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-7018f2df328sm2473506eaf.7.2026.10.16.11.00.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 11:00:50 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Jeff Layton <jlayton@kernel.org>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH nfs-utils 7/7] Add MAINTAINERS file and get_maintainer.pl
Date: Fri, 16 Oct 2026 14:00:48 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <CB9D6619-8BE3-4D97-B2C6-5C6FBD89EF6E@hammerspace.com>
In-Reply-To: <20261016-netlink-noproc-v1-7-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
 <20261016-netlink-noproc-v1-7-42791f4b6eb5@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 16 Oct 2026, at 10:15, Jeff Layton wrote:

> diff --git a/scripts/get_maintainer.pl b/scripts/get_maintainer.pl
> new file mode 100755
> index 000000000000..90b31c2864de
> --- /dev/null
> +++ b/scripts/get_maintainer.pl
> @@ -0,0 +1,375 @@
> +#!/usr/bin/perl
> +#
> +# scripts/get_maintainer.pl -- report whom to Cc on an nfs-utils patch
> +#
> +# Copyright (C) 2026  Jeff Layton <jlayton@kernel.org>
> +#
> +# This program is free software; you can redistribute it and/or
> +# modify it under the terms of the GNU General Public License
> +# as published by the Free Software Foundation; either version 2
> +# of the License, or (at your option) any later version.
> +#
> +# This program is distributed in the hope that it will be useful,
> +# but WITHOUT ANY WARRANTY; without even the implied warranty of
> +# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> +# GNU General Public License for more details.
> +#
> +# You should have received a copy of the GNU General Public License
> +# along with this program; if not, write to the Free Software Foundation, Inc.,
> +# 51 Franklin Street, Fifth Floor, Boston, MA 0211-1301 USA

  +# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA


> +#
> +# Reads the MAINTAINERS file at the top of the tree (same section format
> +# as the Linux kernel MAINTAINERS file) and prints the matching M:, R:
> +# and L: entries for the files in a patch.  This is a deliberately small
> +# subset of the kernel scripts/get_maintainer.pl: the F:, X:, N: and K:
> +# match types are supported, but there is no git history fallback and no
> +# interactive mode.  It understands the option subset that "b4 prep
> +# --auto-to-cc" passes, so that command works out of the box:
> +#
> +#	scripts/get_maintainer.pl <patch>
> +#	scripts/get_maintainer.pl -f <file>...
> +#	scripts/get_maintainer.pl --self-test
> +
> +use strict;
> +use warnings;
> +use Getopt::Long qw(:config no_auto_abbrev);
> +use File::Basename qw(basename dirname);
> +use Cwd qw(abs_path);
> +
> +my $P = basename($0);
> +
> +my $email_maintainer = 1;
> +my $email_reviewer = 1;
> +my $email_list = 1;
> +my $output_roles = 1;

^^ output_Roles should default to off because otherwise using this with
b4 mangles adds that "open list:NFS-UTILS" onto the list's email display
name:

b4 prep --auto-to-cc
Collecting To/Cc addresses
    + To: Steve Dickson <steved@redhat.com>
    + Cc: open list:NFS-UTILS <linux-nfs@vger.kernel.org>

> +my $output_rolestats = 0;

.. and --norolestats doesn't seem to fix it.

> +my $output_separator;
> +my $output_multiline = 1;
> +my $do_keywords = 1;
> +my $from_filename = 0;
> +my $maintainer_path;
> +my $self_test;
> +my $show_help = 0;
> +
> +# Accepted and ignored: this implementation never mines git history,
> +# so the git options (and the informational ones below) are no-ops.
> +my %ignored;
> +
> +if (!GetOptions(
> +	'm!' => \$email_maintainer,
> +	'r!' => \$email_reviewer,
> +	'l!' => \$email_list,
> +	'roles!' => \$output_roles,
> +	'rolestats!' => \$output_rolestats,
> +	'separator=s' => \$output_separator,
> +	'multiline!' => \$output_multiline,
> +	'remove-duplicates!' => \$ignored{remove_duplicates},
> +	'f|file' => \$from_filename,
> +	'mpath|maintainer-path=s' => \$maintainer_path,
> +	'k|keywords!' => \$do_keywords,
> +	'self-test:s' => \$self_test,
> +	'help|h|?' => \$show_help,
> +	'email!' => \$ignored{email},
> +	'git!' => \$ignored{git},
> +	'git-all-signature-types!' => \$ignored{git_all_signature_types},
> +	'git-blame!' => \$ignored{git_blame},
> +	'git-blame-signatures!' => \$ignored{git_blame_signatures},
> +	'git-fallback!' => \$ignored{git_fallback},
> +	'git-chief-penguins!' => \$ignored{git_chief_penguins},
> +	'git-min-signatures=i' => \$ignored{git_min_signatures},
> +	'git-max-maintainers=i' => \$ignored{git_max_maintainers},
> +	'git-min-percent=i' => \$ignored{git_min_percent},
> +	'git-since=s' => \$ignored{git_since},
> +	'hg-since=s' => \$ignored{hg_since},
> +	'mailmap!' => \$ignored{mailmap},
> +	'n!' => \$ignored{n},
> +	's!' => \$ignored{s},
> +	'fixes!' => \$ignored{fixes},
> +	'moderated!' => \$ignored{moderated},
> +	'pattern-depth=i' => \$ignored{pattern_depth},
> +	'fe|file-emails!' => \$ignored{file_emails},
> +    )) {
> +    die "usage: $P [options] patchfile\n";
> +}
> +
> +if ($show_help) {
> +    usage();
> +    exit 0;
> +}
> +
> +$output_roles = 1 if ($output_rolestats);
> +$output_multiline = 0
> +    if (defined $output_separator && $output_separator ne ", ");
> +
> +if (-t STDIN && !@ARGV && !defined $self_test) {
> +    die "$P: missing patchfile or -f file - use --help if necessary\n";
> +}
> +
> +my $topdir = find_toplevel();
> +my $maint_file = $maintainer_path // "$topdir/MAINTAINERS";
> +die "$P: MAINTAINER file not found '$maint_file'\n" if (!-f $maint_file);
> +
> +my @sections = read_maintainer_file($maint_file);
> +
> +if (defined $self_test) {
> +    exit(self_test($maint_file, \@sections) ? 1 : 0);
> +}
> +
> +my (@files, @content);
> +if ($from_filename) {
> +    # Accept absolute paths by trimming the tree prefix, like the kernel script
> +    @files = map { my $f = $_; $f =~ s@^\Q$topdir\E/@@; $f } @ARGV;
> +} elsif (@ARGV) {
> +    foreach my $patch (@ARGV) {
> +	open(my $fh, '<', $patch)
> +	    or die "$P: Can't open $patch: $!\n";
> +	push(@content, <$fh>);
> +	close($fh);
> +    }
> +    @files = patch_files(\@content);
> +} else {
> +    @content = <STDIN>;
> +    @files = patch_files(\@content);
> +}
> +
> +# In -f mode with keyword matching, scan the named files themselves.
> +if ($from_filename && $do_keywords) {
> +    foreach my $file (@files) {
> +	next if ($file =~ m@\bMAINTAINERS$@);
> +	my $path = $file =~ m@^/@ ? $file : "$topdir/$file";
> +	next if (!-f $path);
> +	open(my $fh, '<', $path) or next;
> +	push(@content, <$fh>);
> +	close($fh);
> +    }
> +}
> +
> +my @matches = match_sections(\@sections, \@files, \@content);
> +
> +my @out;
> +my %seen;
> +foreach my $m (@matches) {
> +    my ($section, $type, $addr) = @$m;
> +    next if ($type eq 'M' && !$email_maintainer);
> +    next if ($type eq 'R' && !$email_reviewer);
> +    next if ($type eq 'L' && !$email_list);
> +    my $key = $addr =~ /<([^>]+)>/ ? $1 : $addr;
> +    next if ($seen{$key}++);
> +    if ($output_roles) {
> +	my $role = $type eq 'M' ? maintainer_role($section->{S})
> +	    : $type eq 'R' ? 'reviewer'
> +	    : 'open list';
> +	$addr .= " ($role:$section->{name})";
> +    }
> +    push(@out, $addr);
> +}
> +
> +if ($output_multiline) {
> +    print "$_\n" foreach (@out);
> +} elsif (@out) {
> +    print join($output_separator // ", ", @out) . "\n";
> +}
> +
> +exit 0;
> +
> +sub usage {
> +    print <<EOT;
> +usage: $P [options] patchfile
> +       $P [options] -f file...
> +       $P --self-test
> +
> +Print the MAINTAINERS entries (maintainers, reviewers, lists) for the
> +files changed by a patch.  With no patchfile argument, the patch is
> +read from standard input.
> +
> +  --m, --r, --l	    include maintainers, reviewers, lists
> +		    (prefix with "no" to exclude, e.g. --nom)
> +  --roles	    show roles (default)
> +  --rolestats	    show roles (no statistics in this implementation)
> +  --separator=X	    join addresses with X instead of newlines
> +  -f, --file	    arguments are file names, not patches
> +  --mpath=PATH	    use PATH as the MAINTAINERS file
> +  -k, --keywords    match K: content patterns (default)
> +  --self-test	    validate the MAINTAINERS file
> +
> +The --git* options are accepted for compatibility with the kernel
> +scripts/get_maintainer.pl and b4, but ignored: this implementation
> +only matches MAINTAINERS patterns, it never mines git history.
> +EOT
> +}
> +
> +sub find_toplevel {
> +    my $dir = qx(git rev-parse --show-toplevel 2>/dev/null);
> +    chomp $dir if (defined $dir);
> +    if (!defined $dir || $dir eq '' || !-d $dir) {
> +        # Not in a git checkout (e.g. a release tarball): the tree top
> +        # is the parent of the directory holding this script.
> +        $dir = dirname(abs_path($0)) . '/..';
> +    }
> +    return $dir;
> +}

This finds the top of whatever git tree the cwd is in, not the tree
the script lives in.  Running it from a kernel tree:

  $ cd linux
  $ ~/nfs-utils/scripts/get_maintainer.pl -f fs/nfsd/export.c

reads the kernel's MAINTAINERS and prints the knfsd maintainers.

The fallback also leaves "scripts/.." in $topdir, so the -f prefix
strip never matches an absolute path when run from a tarball.

Maybe just always use the script's location:

        return abs_path(dirname(abs_path($0)) . '/..');

b4 runs it from the tree top, so that wouldn't change anything there.

Ben
